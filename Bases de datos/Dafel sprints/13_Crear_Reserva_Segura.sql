USE DaferDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CrearReserva
    @id_version INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @id_reserva INT,
        @resultado_bloqueo INT,
        @conflicto BIT = 0;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        -- Evita que dos ejecuciones de este
        -- procedimiento reserven simultaneamente.

        EXEC @resultado_bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Reservas',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @resultado_bloqueo < 0
            THROW 50100,
                'No fue posible obtener el bloqueo de reservas.',
                1;

        -- La cotizacion debe estar aceptada.

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.VersionCotizacion WITH (UPDLOCK, HOLDLOCK)
            WHERE id_version = @id_version
              AND estado = 'ACEPTADA'
        )
            THROW 50101,
                'La version no existe o no esta aceptada.',
                1;

        -- No permitir otra reserva para la misma version.

        IF EXISTS (
            SELECT 1
            FROM dbo.Reserva WITH (UPDLOCK, HOLDLOCK)
            WHERE id_version = @id_version
        )
            THROW 50102,
                'La version ya tiene una reserva registrada.',
                1;

        -- La version debe tener equipos fisicos.

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DetalleCotizacion dc
            INNER JOIN dbo.Recurso r
                ON r.id_recurso = dc.id_recurso
            WHERE dc.id_version = @id_version
              AND r.naturaleza = 'EQUIPO'
        )
            THROW 50103,
                'La version no contiene equipos para reservar.',
                1;

        -- Crear cabecera de reserva.

        INSERT INTO dbo.Reserva
        (
            id_version,
            estado
        )
        VALUES
        (
            @id_version,
            'ACTIVA'
        );

        SET @id_reserva = CONVERT(INT, SCOPE_IDENTITY());

        -- Copiar los equipos cotizados.
        -- Los servicios de personal se gestionan aparte.

        INSERT INTO dbo.DetalleReserva
        (
            id_reserva,
            id_detalle_cotizacion,
            id_recurso,
            cantidad,
            fecha_inicio,
            fecha_fin
        )
        SELECT
            @id_reserva,
            dc.id_detalle_cotizacion,
            dc.id_recurso,
            dc.cantidad,
            dc.fecha_inicio,
            dc.fecha_fin
        FROM dbo.DetalleCotizacion dc
        INNER JOIN dbo.Recurso r
            ON r.id_recurso = dc.id_recurso
        WHERE dc.id_version = @id_version
          AND r.naturaleza = 'EQUIPO';

        -- Revisar todos los puntos donde puede
        -- cambiar la cantidad reservada.
        -- Incluye las lineas de la nueva reserva.

        ;WITH RecursosNuevos AS
        (
            SELECT DISTINCT id_recurso
            FROM dbo.DetalleReserva
            WHERE id_reserva = @id_reserva
        ),
        Instantes AS
        (
            SELECT DISTINCT
                dr.id_recurso,
                dr.fecha_inicio AS instante
            FROM dbo.DetalleReserva dr
            INNER JOIN dbo.Reserva rv
                ON rv.id_reserva = dr.id_reserva
            INNER JOIN RecursosNuevos rn
                ON rn.id_recurso = dr.id_recurso
            WHERE rv.estado = 'ACTIVA'
              AND EXISTS
              (
                  SELECT 1
                  FROM dbo.DetalleReserva nueva
                  WHERE nueva.id_reserva = @id_reserva
                    AND nueva.id_recurso = dr.id_recurso
                    AND dr.fecha_inicio >= nueva.fecha_inicio
                    AND dr.fecha_inicio < nueva.fecha_fin
              )

            UNION

            SELECT DISTINCT
                id_recurso,
                fecha_inicio
            FROM dbo.DetalleReserva
            WHERE id_reserva = @id_reserva
        ),
        Existencias AS
        (
            SELECT
                i.id_recurso,
                SUM(CONVERT(BIGINT, i.cantidad)) AS disponibles
            FROM dbo.Inventario i
            INNER JOIN dbo.CondicionMaterial cm
                ON cm.id_condicion = i.id_condicion
            INNER JOIN dbo.Bodega b
                ON b.id_bodega = i.id_bodega
            INNER JOIN RecursosNuevos rn
                ON rn.id_recurso = i.id_recurso
            WHERE cm.permite_despacho = 1
              AND b.activo = 1
            GROUP BY i.id_recurso
        )
        SELECT @conflicto =
            CASE WHEN EXISTS
            (
                SELECT 1
                FROM Instantes t
                LEFT JOIN Existencias e
                    ON e.id_recurso = t.id_recurso
                CROSS APPLY
                (
                    SELECT
                        COALESCE(
                            SUM(CONVERT(BIGINT, dr.cantidad)),
                            0
                        ) AS comprometidas
                    FROM dbo.DetalleReserva dr
                    INNER JOIN dbo.Reserva rv
                        ON rv.id_reserva = dr.id_reserva
                    WHERE dr.id_recurso = t.id_recurso
                      AND rv.estado = 'ACTIVA'
                      AND dr.fecha_inicio <= t.instante
                      AND dr.fecha_fin > t.instante
                ) ocupacion
                WHERE ocupacion.comprometidas >
                      COALESCE(e.disponibles, 0)
            )
            THEN 1 ELSE 0 END;

        IF @conflicto = 1
            THROW 50104,
                'Inventario insuficiente para el periodo solicitado.',
                1;

        COMMIT TRANSACTION;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        SELECT
            @id_reserva AS id_reserva,
            @id_version AS id_version,
            'ACTIVA' AS estado,
            'Reserva creada correctamente' AS resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        THROW;
    END CATCH;
END;
GO