USE DaferDB;
GO

-- 1. AGREGAR ESTADO AL MOVIMIENTO
-- Ejecutar una sola vez.

IF COL_LENGTH(
    'dbo.MovimientoInventario', 'estado'
) IS NULL
BEGIN
    ALTER TABLE dbo.MovimientoInventario
    ADD estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_MovimientoInventario_estado
        DEFAULT 'PENDIENTE'
        WITH VALUES;
END;
GO

-- 2. RESTRINGIR LOS ESTADOS PERMITIDOS

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_MovimientoInventario_estado'
      AND parent_object_id =
          OBJECT_ID('dbo.MovimientoInventario')
)
BEGIN
    ALTER TABLE dbo.MovimientoInventario
    ADD CONSTRAINT CK_MovimientoInventario_estado
    CHECK (estado IN (
        'PENDIENTE',
        'CONFIRMADO',
        'ANULADO'
    ));
END;
GO

-- 3. PROCEDIMIENTO DE CONFIRMACION

CREATE OR ALTER PROCEDURE dbo.sp_ConfirmarMovimientoInventario
    @id_movimiento INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @id_recurso INT,
        @id_bodega_origen INT,
        @id_condicion_origen INT,
        @id_bodega_destino INT,
        @id_condicion_destino INT,
        @cantidad INT,
        @estado VARCHAR(20);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        BEGIN TRANSACTION;

        -- Bloquear el movimiento mientras se procesa.

        SELECT @estado = estado
        FROM dbo.MovimientoInventario
            WITH (UPDLOCK, HOLDLOCK)
        WHERE id_movimiento = @id_movimiento;

        IF @estado IS NULL
            THROW 50001,
                'El movimiento no existe.', 1;

        IF @estado <> 'PENDIENTE'
            THROW 50002,
                'El movimiento no esta pendiente.', 1;

        -- Debe existir al menos una linea.

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DetalleMovimientoInventario
            WHERE id_movimiento = @id_movimiento
        )
            THROW 50003,
                'El movimiento no tiene detalles.', 1;

        -- Solo EQUIPO puede manejarse como inventario.

        IF EXISTS (
            SELECT 1
            FROM dbo.DetalleMovimientoInventario d
            INNER JOIN dbo.Recurso r
                ON r.id_recurso = d.id_recurso
            WHERE d.id_movimiento = @id_movimiento
              AND r.naturaleza <> 'EQUIPO'
        )
            THROW 50004,
                'Un servicio de personal no puede mover inventario.', 1;

        -- Procesar cada linea en orden deterministico.
        -- El procedimiento debe ejecutarse mediante
        -- acceso controlado a las tablas.

        DECLARE movimiento_cursor CURSOR LOCAL FAST_FORWARD
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

        OPEN movimiento_cursor;

        FETCH NEXT FROM movimiento_cursor INTO
            @id_recurso,
            @id_bodega_origen,
            @id_condicion_origen,
            @id_bodega_destino,
            @id_condicion_destino,
            @cantidad;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            -- A. DESCONTAR DEL ORIGEN

            IF @id_bodega_origen IS NOT NULL
            BEGIN
                UPDATE dbo.Inventario
                SET cantidad = cantidad - @cantidad
                WHERE id_recurso = @id_recurso
                  AND id_bodega = @id_bodega_origen
                  AND id_condicion = @id_condicion_origen
                  AND cantidad >= @cantidad;

                IF @@ROWCOUNT <> 1
                    THROW 50005,
                        'Existencias insuficientes en el origen.', 1;
            END;

            -- B. SUMAR AL DESTINO

            IF @id_bodega_destino IS NOT NULL
            BEGIN
                -- Las busquedas se protegen bajo SERIALIZABLE
                -- para evitar inserciones simultaneas duplicadas.

                IF EXISTS (
                    SELECT 1
                    FROM dbo.Inventario WITH (UPDLOCK, HOLDLOCK)
                    WHERE id_recurso = @id_recurso
                      AND id_bodega = @id_bodega_destino
                      AND id_condicion = @id_condicion_destino
                )
                BEGIN
                    UPDATE dbo.Inventario
                    SET cantidad = cantidad + @cantidad
                    WHERE id_recurso = @id_recurso
                      AND id_bodega = @id_bodega_destino
                      AND id_condicion = @id_condicion_destino;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.Inventario
                    (
                        id_recurso,
                        id_bodega,
                        id_condicion,
                        cantidad
                    )
                    VALUES
                    (
                        @id_recurso,
                        @id_bodega_destino,
                        @id_condicion_destino,
                        @cantidad
                    );
                END;
            END;

            FETCH NEXT FROM movimiento_cursor INTO
                @id_recurso,
                @id_bodega_origen,
                @id_condicion_origen,
                @id_bodega_destino,
                @id_condicion_destino,
                @cantidad;
        END;

        CLOSE movimiento_cursor;
        DEALLOCATE movimiento_cursor;

        -- Confirmar solamente si todo fue correcto.

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

        IF CURSOR_STATUS('local', 'movimiento_cursor') >= 0
            CLOSE movimiento_cursor;

        IF CURSOR_STATUS('local', 'movimiento_cursor') >= -1
            DEALLOCATE movimiento_cursor;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        THROW;
    END CATCH;
END;
GO