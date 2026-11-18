USE DaferDB;
GO

-- 1. RELACIONAR DESPACHOS CON MOVIMIENTOS

IF COL_LENGTH('dbo.Despacho', 'id_movimiento') IS NULL
BEGIN
    ALTER TABLE dbo.Despacho
    ADD id_movimiento INT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Despacho_Movimiento'
)
BEGIN
    ALTER TABLE dbo.Despacho
    ADD CONSTRAINT FK_Despacho_Movimiento
    FOREIGN KEY (id_movimiento)
    REFERENCES dbo.MovimientoInventario(id_movimiento);
END;
GO

-- 2. RELACIONAR DEVOLUCIONES CON MOVIMIENTOS

IF COL_LENGTH('dbo.Devolucion', 'id_movimiento') IS NULL
BEGIN
    ALTER TABLE dbo.Devolucion
    ADD id_movimiento INT NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Devolucion_Movimiento'
)
BEGIN
    ALTER TABLE dbo.Devolucion
    ADD CONSTRAINT FK_Devolucion_Movimiento
    FOREIGN KEY (id_movimiento)
    REFERENCES dbo.MovimientoInventario(id_movimiento);
END;
GO

-- 3. IMPEDIR REUTILIZAR UN MOVIMIENTO
-- ENTRE VARIOS DESPACHOS

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_Despacho_Movimiento'
      AND object_id = OBJECT_ID('dbo.Despacho')
)
BEGIN
    CREATE UNIQUE INDEX UX_Despacho_Movimiento
    ON dbo.Despacho(id_movimiento)
    WHERE id_movimiento IS NOT NULL;
END;
GO

-- 4. IMPEDIR REUTILIZAR UN MOVIMIENTO
-- ENTRE VARIAS DEVOLUCIONES

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'UX_Devolucion_Movimiento'
      AND object_id = OBJECT_ID('dbo.Devolucion')
)
BEGIN
    CREATE UNIQUE INDEX UX_Devolucion_Movimiento
    ON dbo.Devolucion(id_movimiento)
    WHERE id_movimiento IS NOT NULL;
END;
GO

-- 5. CONSULTA UNIFICADA DE TRAZABILIDAD

CREATE OR ALTER VIEW dbo.vw_TrazabilidadMovimientos
AS
SELECT
    'DESPACHO' AS tipo_operacion,
    d.id_despacho AS id_operacion,
    d.id_alquiler,
    d.id_movimiento,
    m.fecha_movimiento,
    m.estado AS estado_movimiento
FROM dbo.Despacho d
LEFT JOIN dbo.MovimientoInventario m
    ON m.id_movimiento = d.id_movimiento

UNION ALL

SELECT
    'DEVOLUCION',
    dv.id_devolucion,
    dv.id_alquiler,
    dv.id_movimiento,
    m.fecha_movimiento,
    m.estado
FROM dbo.Devolucion dv
LEFT JOIN dbo.MovimientoInventario m
    ON m.id_movimiento = dv.id_movimiento;
GO