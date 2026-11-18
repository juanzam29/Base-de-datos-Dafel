USE DaferDB;
GO

-- 1. VALIDAR Y COMPLETAR INSPECCION

CREATE OR ALTER PROCEDURE dbo.sp_CompletarInspeccion
    @id_inspeccion INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @cantidad_recibida BIGINT,
        @cantidad_clasificada BIGINT,
        @estado VARCHAR(20),
        @bloqueo INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Inspecciones',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50400, 'No se obtuvo el bloqueo.', 1;

        SELECT
            @cantidad_recibida = dd.cantidad_recibida,
            @estado = i.estado
        FROM dbo.InspeccionDevolucion i
            WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.DetalleDevolucion dd
            ON dd.id_detalle_devolucion =
               i.id_detalle_devolucion
        INNER JOIN dbo.Devolucion d
            ON d.id_devolucion = dd.id_devolucion
        WHERE i.id_inspeccion = @id_inspeccion
          AND d.estado <> 'ANULADA';

        IF @cantidad_recibida IS NULL
            THROW 50401, 'Inspeccion no valida.', 1;

        IF @estado <> 'PENDIENTE'
            THROW 50402, 'Inspeccion no pendiente.', 1;

        SELECT @cantidad_clasificada =
            COALESCE(SUM(CONVERT(BIGINT, cantidad)), 0)
        FROM dbo.DetalleInspeccion
        WHERE id_inspeccion = @id_inspeccion;

        IF @cantidad_clasificada <> @cantidad_recibida
            THROW 50403,
                'La cantidad clasificada no coincide con la recibida.',
                1;

        UPDATE dbo.InspeccionDevolucion
        SET estado = 'COMPLETADA'
        WHERE id_inspeccion = @id_inspeccion;

        COMMIT TRANSACTION;

        SELECT 'INSPECCION COMPLETADA' AS resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 2. CERRAR OPERATIVAMENTE UN ALQUILER

CREATE OR ALTER PROCEDURE dbo.sp_CerrarAlquiler
    @id_alquiler INT,
    @id_usuario INT,
    @con_novedades BIT = 0,
    @observaciones NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @estado VARCHAR(20),
        @bloqueo INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Cierres',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50410, 'No se obtuvo el bloqueo.', 1;

        SELECT @estado = estado
        FROM dbo.Alquiler WITH (UPDLOCK, HOLDLOCK)
        WHERE id_alquiler = @id_alquiler;

        IF @estado IS NULL
            THROW 50411, 'Alquiler inexistente.', 1;

        IF @estado NOT IN ('PENDIENTE', 'EN_EJECUCION')
            THROW 50412,
                'El alquiler no admite cierre.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.CierreAlquiler
            WHERE id_alquiler = @id_alquiler
        )
            THROW 50413,
                'El alquiler ya tiene cierre.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Usuario
            WHERE id_usuario = @id_usuario
              AND activo = 1
        )
            THROW 50414,
                'Usuario no valido.', 1;

        -- Verificar inspecciones pendientes.

        IF EXISTS (
            SELECT 1
            FROM dbo.InspeccionDevolucion i
            INNER JOIN dbo.DetalleDevolucion dd
                ON dd.id_detalle_devolucion =
                   i.id_detalle_devolucion
            INNER JOIN dbo.Devolucion d
                ON d.id_devolucion = dd.id_devolucion
            WHERE d.id_alquiler = @id_alquiler
              AND d.estado <> 'ANULADA'
              AND i.estado <> 'COMPLETADA'
        )
            THROW 50415,
                'Existen inspecciones pendientes.', 1;

        -- No aceptar devoluciones sin inspeccion.

        IF EXISTS (
            SELECT 1
            FROM dbo.DetalleDevolucion dd
            INNER JOIN dbo.Devolucion d
                ON d.id_devolucion = dd.id_devolucion
            WHERE d.id_alquiler = @id_alquiler
              AND d.estado <> 'ANULADA'
              AND NOT EXISTS (
                  SELECT 1
                  FROM dbo.InspeccionDevolucion i
                  WHERE i.id_detalle_devolucion =
                        dd.id_detalle_devolucion
                    AND i.estado = 'COMPLETADA'
              )
        )
            THROW 50416,
                'Existen devoluciones sin inspeccion completa.', 1;

        -- Calcular diferencias entre entregas y devoluciones.

        IF @con_novedades = 0
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM dbo.DetalleAlquiler da
                OUTER APPLY (
                    SELECT COALESCE(
                        SUM(CONVERT(BIGINT, de.cantidad_recibida)), 0
                    ) AS total
                    FROM dbo.DetalleEntrega de
                    INNER JOIN dbo.DetalleDespacho dd
                        ON dd.id_detalle_despacho =
                           de.id_detalle_despacho
                    INNER JOIN dbo.Despacho d
                        ON d.id_despacho = dd.id_despacho
                    INNER JOIN dbo.Entrega e
                        ON e.id_entrega = de.id_entrega
                       AND e.id_despacho = d.id_despacho
                    WHERE dd.id_detalle_alquiler =
                          da.id_detalle_alquiler
                      AND d.estado <> 'CANCELADO'
                ) entregado
                OUTER APPLY (
                    SELECT COALESCE(
                        SUM(CONVERT(BIGINT, dd.cantidad_recibida)), 0
                    ) AS total
                    FROM dbo.DetalleDevolucion dd
                    INNER JOIN dbo.Devolucion d
                        ON d.id_devolucion = dd.id_devolucion
                    WHERE dd.id_detalle_alquiler =
                          da.id_detalle_alquiler
                      AND d.estado <> 'ANULADA'
                ) devuelto
                INNER JOIN dbo.Recurso r
                    ON r.id_recurso = da.id_recurso
                WHERE da.id_alquiler = @id_alquiler
                  AND r.naturaleza = 'EQUIPO'
                  AND entregado.total <> devuelto.total
            )
                THROW 50417,
                    'Hay material pendiente de devolucion.',
                    1;
        END;

        IF @con_novedades = 1
           AND NULLIF(LTRIM(RTRIM(@observaciones)), '') IS NULL
            THROW 50418,
                'El cierre con novedades requiere justificacion.',
                1;

        INSERT INTO dbo.CierreAlquiler
        (
            id_alquiler,
            id_usuario,
            estado,
            observaciones
        )
        VALUES
        (
            @id_alquiler,
            @id_usuario,
            CASE WHEN @con_novedades = 1
                THEN 'CERRADO_CON_NOVEDADES'
                ELSE 'CERRADO'
            END,
            @observaciones
        );

        UPDATE dbo.Alquiler
        SET estado = 'FINALIZADO'
        WHERE id_alquiler = @id_alquiler;

        COMMIT TRANSACTION;

        SELECT 'ALQUILER CERRADO' AS resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO