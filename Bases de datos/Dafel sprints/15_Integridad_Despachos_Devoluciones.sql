USE DaferDB;
GO

-- 1. IDENTIFICAR CADA DETALLE DENTRO DE SU ALQUILER

IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'UQ_DetalleAlquiler_IdAlquiler'
      AND parent_object_id = OBJECT_ID('dbo.DetalleAlquiler')
)
BEGIN
    ALTER TABLE dbo.DetalleAlquiler
    ADD CONSTRAINT UQ_DetalleAlquiler_IdAlquiler
    UNIQUE (id_alquiler, id_detalle_alquiler);
END;
GO

-- 2. DESPACHO Y DETALLE DEBEN SER DEL MISMO ALQUILER

IF COL_LENGTH('dbo.DetalleDespacho', 'id_alquiler') IS NULL
BEGIN
    ALTER TABLE dbo.DetalleDespacho
    ADD id_alquiler INT NULL;
END;
GO

UPDATE dd
SET dd.id_alquiler = d.id_alquiler
FROM dbo.DetalleDespacho dd
INNER JOIN dbo.Despacho d
    ON d.id_despacho = dd.id_despacho
WHERE dd.id_alquiler IS NULL;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.DetalleDespacho dd
    INNER JOIN dbo.Despacho d
        ON d.id_despacho = dd.id_despacho
    INNER JOIN dbo.DetalleAlquiler da
        ON da.id_detalle_alquiler = dd.id_detalle_alquiler
    WHERE d.id_alquiler <> da.id_alquiler
)
    THROW 50200,
        'Existen detalles de despacho asociados a otro alquiler.',
        1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'UQ_Despacho_IdAlquiler'
      AND parent_object_id = OBJECT_ID('dbo.Despacho')
)
BEGIN
    ALTER TABLE dbo.Despacho
    ADD CONSTRAINT UQ_Despacho_IdAlquiler
    UNIQUE (id_despacho, id_alquiler);
END;
GO

ALTER TABLE dbo.DetalleDespacho
ALTER COLUMN id_alquiler INT NOT NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DetalleDespacho_Contrato'
)
BEGIN
    ALTER TABLE dbo.DetalleDespacho
    ADD CONSTRAINT FK_DetalleDespacho_Contrato
    FOREIGN KEY (id_despacho, id_alquiler)
    REFERENCES dbo.Despacho(id_despacho, id_alquiler);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DetalleDespacho_LineaContrato'
)
BEGIN
    ALTER TABLE dbo.DetalleDespacho
    ADD CONSTRAINT FK_DetalleDespacho_LineaContrato
    FOREIGN KEY (id_alquiler, id_detalle_alquiler)
    REFERENCES dbo.DetalleAlquiler
        (id_alquiler, id_detalle_alquiler);
END;
GO

-- 3. MISMA VALIDACION PARA DEVOLUCIONES

IF COL_LENGTH('dbo.DetalleDevolucion', 'id_alquiler') IS NULL
BEGIN
    ALTER TABLE dbo.DetalleDevolucion
    ADD id_alquiler INT NULL;
END;
GO

UPDATE dd
SET dd.id_alquiler = d.id_alquiler
FROM dbo.DetalleDevolucion dd
INNER JOIN dbo.Devolucion d
    ON d.id_devolucion = dd.id_devolucion
WHERE dd.id_alquiler IS NULL;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.DetalleDevolucion dd
    INNER JOIN dbo.Devolucion d
        ON d.id_devolucion = dd.id_devolucion
    INNER JOIN dbo.DetalleAlquiler da
        ON da.id_detalle_alquiler = dd.id_detalle_alquiler
    WHERE d.id_alquiler <> da.id_alquiler
)
    THROW 50201,
        'Existen devoluciones asociadas a otro alquiler.',
        1;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.key_constraints
    WHERE name = 'UQ_Devolucion_IdAlquiler'
      AND parent_object_id = OBJECT_ID('dbo.Devolucion')
)
BEGIN
    ALTER TABLE dbo.Devolucion
    ADD CONSTRAINT UQ_Devolucion_IdAlquiler
    UNIQUE (id_devolucion, id_alquiler);
END;
GO

ALTER TABLE dbo.DetalleDevolucion
ALTER COLUMN id_alquiler INT NOT NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DetalleDevolucion_Contrato'
)
BEGIN
    ALTER TABLE dbo.DetalleDevolucion
    ADD CONSTRAINT FK_DetalleDevolucion_Contrato
    FOREIGN KEY (id_devolucion, id_alquiler)
    REFERENCES dbo.Devolucion(id_devolucion, id_alquiler);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_DetalleDevolucion_LineaContrato'
)
BEGIN
    ALTER TABLE dbo.DetalleDevolucion
    ADD CONSTRAINT FK_DetalleDevolucion_LineaContrato
    FOREIGN KEY (id_alquiler, id_detalle_alquiler)
    REFERENCES dbo.DetalleAlquiler
        (id_alquiler, id_detalle_alquiler);
END;
GO