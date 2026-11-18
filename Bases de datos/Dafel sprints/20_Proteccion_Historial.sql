USE DaferDB;
GO

-- 1. PROTEGER MOVIMIENTOS CONFIRMADOS

CREATE OR ALTER TRIGGER dbo.TR_ProtegerMovimiento
ON dbo.MovimientoInventario
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- No permitir eliminar ni alterar
    -- movimientos ya confirmados o anulados.

    IF EXISTS (
        SELECT 1
        FROM deleted d
        LEFT JOIN inserted i
            ON i.id_movimiento = d.id_movimiento
        WHERE d.estado IN ('CONFIRMADO', 'ANULADO')
    )
    BEGIN
        THROW 50701,
            'No se puede modificar un movimiento finalizado.',
            1;
    END;

    -- Solo permitir transiciones desde PENDIENTE.
    -- En una confirmacion no se pueden cambiar
    -- los atributos historicos.

    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN inserted i
            ON i.id_movimiento = d.id_movimiento
        WHERE
            i.estado <> d.estado
            AND (
                i.estado NOT IN ('CONFIRMADO', 'ANULADO')
                OR i.id_tipo_movimiento <>
                   d.id_tipo_movimiento
                OR i.id_usuario <> d.id_usuario
                OR i.fecha_movimiento <> d.fecha_movimiento
                OR ISNULL(i.referencia, '') <>
                   ISNULL(d.referencia, '')
                OR ISNULL(i.observaciones, '') <>
                   ISNULL(d.observaciones, '')
            )
    )
    BEGIN
        THROW 50702,
            'Transicion o modificacion no permitida.',
            1;
    END;
END;
GO

-- 2. PROTEGER DETALLES DE MOVIMIENTOS
-- QUE YA NO ESTAN PENDIENTES

CREATE OR ALTER TRIGGER dbo.TR_ProtegerDetalleMovimiento
ON dbo.DetalleMovimientoInventario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.MovimientoInventario m
            ON m.id_movimiento = i.id_movimiento
        WHERE m.estado <> 'PENDIENTE'
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN dbo.MovimientoInventario m
            ON m.id_movimiento = d.id_movimiento
        WHERE m.estado <> 'PENDIENTE'
    )
    BEGIN
        THROW 50703,
            'No se pueden alterar detalles de un movimiento finalizado.',
            1;
    END;
END;
GO

-- 3. CREAR ROL DE APLICACION

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'rol_dafer_aplicacion'
      AND type = 'R'
)
BEGIN
    CREATE ROLE rol_dafer_aplicacion;
END;
GO

-- 4. CONCEDER EJECUCION A LOS PROCEDIMIENTOS

GRANT EXECUTE ON SCHEMA::dbo
TO rol_dafer_aplicacion;
GO