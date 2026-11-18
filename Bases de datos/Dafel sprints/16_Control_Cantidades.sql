USE DaferDB;
GO

-- 1. REGISTRAR UNA ENTREGA CONTROLADA

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarDetalleEntrega
    @id_entrega INT,
    @id_detalle_despacho INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @id_alquiler INT,
        @id_despacho INT,
        @cantidad_despachada BIGINT,
        @cantidad_entregada BIGINT,
        @bloqueo INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @id_despacho = e.id_despacho
        FROM dbo.Entrega e WITH (UPDLOCK, HOLDLOCK)
        WHERE e.id_entrega = @id_entrega;

        IF @id_despacho IS NULL
            THROW 50301, 'La entrega no existe.', 1;

        SELECT
            @id_alquiler = d.id_alquiler
        FROM dbo.Despacho d
        WHERE d.id_despacho = @id_despacho
          AND d.estado <> 'CANCELADO';

        IF @id_alquiler IS NULL
            THROW 50302,
                'El despacho no es valido.', 1;

        IF @cantidad <= 0
            THROW 50303,
                'La cantidad debe ser positiva.', 1;

        -- Serializar registros de entrega
        -- del mismo detalle de despacho.

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Entrega',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50304,
                'No fue posible bloquear las entregas.', 1;

        SELECT
            @cantidad_despachada = dd.cantidad
        FROM dbo.DetalleDespacho dd WITH (UPDLOCK, HOLDLOCK)
        WHERE dd.id_detalle_despacho = @id_detalle_despacho
          AND dd.id_despacho = @id_despacho;

        IF @cantidad_despachada IS NULL
            THROW 50305,
                'El detalle no pertenece al despacho.', 1;

        SELECT
            @cantidad_entregada =
                COALESCE(SUM(CONVERT(BIGINT, de.cantidad_recibida)), 0)
        FROM dbo.DetalleEntrega de
        INNER JOIN dbo.Entrega e
            ON e.id_entrega = de.id_entrega
        WHERE de.id_detalle_despacho = @id_detalle_despacho;

        IF @cantidad_entregada + @cantidad
            > @cantidad_despachada
            THROW 50306,
                'La entrega supera la cantidad despachada.', 1;

        INSERT INTO dbo.DetalleEntrega
        (
            id_entrega,
            id_detalle_despacho,
            cantidad_recibida
        )
        VALUES
        (
            @id_entrega,
            @id_detalle_despacho,
            @cantidad
        );

        COMMIT TRANSACTION;

        SELECT 'ENTREGA REGISTRADA' AS resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 2. REGISTRAR UNA DEVOLUCION CONTROLADA

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarDetalleDevolucion
    @id_devolucion INT,
    @id_detalle_alquiler INT,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @id_alquiler INT,
        @total_entregado BIGINT,
        @total_devuelto BIGINT,
        @bloqueo INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @id_alquiler = d.id_alquiler
        FROM dbo.Devolucion d WITH (UPDLOCK, HOLDLOCK)
        WHERE d.id_devolucion = @id_devolucion
          AND d.estado IN ('REGISTRADA', 'EN_INSPECCION');

        IF @id_alquiler IS NULL
            THROW 50310,
                'La devolucion no existe o no admite detalles.',
                1;

        IF @cantidad <= 0
            THROW 50311,
                'La cantidad debe ser positiva.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.DetalleAlquiler
            WHERE id_detalle_alquiler = @id_detalle_alquiler
              AND id_alquiler = @id_alquiler
        )
            THROW 50312,
                'El detalle no pertenece al alquiler.', 1;

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_Devoluciones',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50313,
                'No fue posible bloquear las devoluciones.', 1;

        -- Cantidad efectivamente entregada.

        SELECT
            @total_entregado =
                COALESCE(SUM(CONVERT(BIGINT, de.cantidad_recibida)), 0)
        FROM dbo.DetalleEntrega de
        INNER JOIN dbo.DetalleDespacho dd
            ON dd.id_detalle_despacho = de.id_detalle_despacho
        INNER JOIN dbo.Entrega e
            ON e.id_entrega = de.id_entrega
           AND e.id_despacho = dd.id_despacho
        INNER JOIN dbo.Despacho d
            ON d.id_despacho = dd.id_despacho
        WHERE dd.id_detalle_alquiler = @id_detalle_alquiler
          AND d.id_alquiler = @id_alquiler
          AND d.estado <> 'CANCELADO';

        -- Cantidad previamente devuelta.

        SELECT
            @total_devuelto =
                COALESCE(SUM(CONVERT(BIGINT, dd.cantidad_recibida)), 0)
        FROM dbo.DetalleDevolucion dd
        INNER JOIN dbo.Devolucion d
            ON d.id_devolucion = dd.id_devolucion
        WHERE dd.id_detalle_alquiler = @id_detalle_alquiler
          AND d.estado <> 'ANULADA';

        IF @total_devuelto + @cantidad > @total_entregado
            THROW 50314,
                'La devolucion supera las unidades entregadas.',
                1;

        DECLARE @numero_linea INT;

        SELECT @numero_linea =
            COALESCE(MAX(numero_linea), 0) + 1
        FROM dbo.DetalleDevolucion
        WHERE id_devolucion = @id_devolucion;

        INSERT INTO dbo.DetalleDevolucion
        (
            id_devolucion,
            id_detalle_alquiler,
            id_alquiler,
            numero_linea,
            cantidad_recibida
        )
        VALUES
        (
            @id_devolucion,
            @id_detalle_alquiler,
            @id_alquiler,
            @numero_linea,
            @cantidad
        );

        COMMIT TRANSACTION;

        SELECT 'DEVOLUCION REGISTRADA' AS resultado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO