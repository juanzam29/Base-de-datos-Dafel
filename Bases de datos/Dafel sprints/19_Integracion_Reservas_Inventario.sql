USE DaferDB;
GO

-- ACTUALIZAR CONFIRMACION DE MOVIMIENTOS

CREATE OR ALTER PROCEDURE dbo.sp_ConfirmarMovimientoInventario
    @id_movimiento INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @bloqueo INT,
        @estado VARCHAR(20),
        @recurso INT,
        @bodega_origen INT,
        @condicion_origen INT,
        @bodega_destino INT,
        @condicion_destino INT,
        @cantidad INT,
        @ahora DATETIME2(0) = SYSDATETIME();

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        -- Mismo bloqueo utilizado al crear reservas.

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Reservas',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50601,
                'No se pudo bloquear el inventario.',
                1;

        SELECT @estado = estado
        FROM dbo.MovimientoInventario WITH (UPDLOCK, HOLDLOCK)
        WHERE id_movimiento = @id_movimiento;

        IF @estado IS NULL OR @estado <> 'PENDIENTE'
            THROW 50602,
                'Movimiento inexistente o no pendiente.',
                1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DetalleMovimientoInventario
            WHERE id_movimiento = @id_movimiento
        )
            THROW 50603,
                'El movimiento no tiene detalles.',
                1;

        IF EXISTS (
            SELECT 1
            FROM dbo.DetalleMovimientoInventario d
            INNER JOIN dbo.Recurso r
                ON r.id_recurso = d.id_recurso
            WHERE d.id_movimiento = @id_movimiento
              AND r.naturaleza <> 'EQUIPO'
        )
            THROW 50604,
                'El inventario solo admite equipos.',
                1;

        DECLARE movimientos CURSOR LOCAL FAST_FORWARD
        FOR
            SELECT
                id_recurso,
                id_bodega_origen,
                id_condicion_origen,
                id_bodega_destino,
                id_condicion_destino,
                cantidad
            FROM dbo.DetalleMovimientoInventario
            WHERE id_movimiento = @id_movimiento
            ORDER BY id_detalle_movimiento;

        OPEN movimientos;

        FETCH NEXT FROM movimientos INTO
            @recurso, @bodega_origen, @condicion_origen,
            @bodega_destino, @condicion_destino, @cantidad;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Retirar del origen.

            IF @bodega_origen IS NOT NULL
            BEGIN
                UPDATE dbo.Inventario
                SET cantidad = cantidad - @cantidad
                WHERE id_recurso = @recurso
                  AND id_bodega = @bodega_origen
                  AND id_condicion = @condicion_origen
                  AND cantidad >= @cantidad;

                IF @@ROWCOUNT <> 1
                    THROW 50605,
                        'Existencias insuficientes en origen.',
                        1;
            END;

            -- Incorporar al destino.

            IF @bodega_destino IS NOT NULL
            BEGIN
                UPDATE dbo.Inventario WITH (UPDLOCK, HOLDLOCK)
                SET cantidad = cantidad + @cantidad
                WHERE id_recurso = @recurso
                  AND id_bodega = @bodega_destino
                  AND id_condicion = @condicion_destino;

                IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO dbo.Inventario
                    (
                        id_recurso, id_bodega,
                        id_condicion, cantidad
                    )
                    VALUES
                    (
                        @recurso, @bodega_destino,
                        @condicion_destino, @cantidad
                    );
                END;
            END;

            FETCH NEXT FROM movimientos INTO
                @recurso, @bodega_origen, @condicion_origen,
                @bodega_destino, @condicion_destino, @cantidad;
        END;

        CLOSE movimientos;
        DEALLOCATE movimientos;

        -- VALIDAR COBERTURA DE RESERVAS DESPUES DEL CAMBIO
        -- Se revisan los puntos de inicio de cada reserva
        -- activa que todavia no ha terminado.

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT DISTINCT
                    dr.id_recurso,
                    CASE
                        WHEN dr.fecha_inicio < @ahora
                        THEN @ahora
                        ELSE dr.fecha_inicio
                    END AS instante
                FROM dbo.DetalleReserva dr
                INNER JOIN dbo.Reserva rv
                    ON rv.id_reserva = dr.id_reserva
                WHERE rv.estado = 'ACTIVA'
                  AND dr.fecha_fin > @ahora
            ) t
            OUTER APPLY
            (
                SELECT SUM(CONVERT(BIGINT, i.cantidad))
                    AS disponible
                FROM dbo.Inventario i
                INNER JOIN dbo.CondicionMaterial c
                    ON c.id_condicion = i.id_condicion
                INNER JOIN dbo.Bodega b
                    ON b.id_bodega = i.id_bodega
                WHERE i.id_recurso = t.id_recurso
                  AND c.permite_despacho = 1
                  AND b.activo = 1
            ) stock
            OUTER APPLY
            (
                SELECT SUM(CONVERT(BIGINT, dr.cantidad))
                    AS comprometido
                FROM dbo.DetalleReserva dr
                INNER JOIN dbo.Reserva rv
                    ON rv.id_reserva = dr.id_reserva
                WHERE dr.id_recurso = t.id_recurso
                  AND rv.estado = 'ACTIVA'
                  AND dr.fecha_inicio <= t.instante
                  AND dr.fecha_fin > t.instante
            ) reservas
            WHERE COALESCE(reservas.comprometido, 0)
                > COALESCE(stock.disponible, 0)
        )
            THROW 50606,
                'El movimiento dejaria reservas sin cobertura.',
                1;

        UPDATE dbo.MovimientoInventario
        SET estado = 'CONFIRMADO'
        WHERE id_movimiento = @id_movimiento;

        COMMIT TRANSACTION;
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        SELECT
            @id_movimiento AS id_movimiento,
            'CONFIRMADO' AS resultado;

    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'movimientos') >= 0
            CLOSE movimientos;

        IF CURSOR_STATUS('local', 'movimientos') >= -1
            DEALLOCATE movimientos;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        THROW;
    END CATCH;
END;
GO