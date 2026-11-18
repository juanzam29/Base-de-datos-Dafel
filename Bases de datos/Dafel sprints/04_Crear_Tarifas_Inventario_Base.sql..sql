USE DaferDB;
GO

CREATE TABLE dbo.UnidadCobro
(
    id_unidad_cobro INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NULL,

    CONSTRAINT PK_UnidadCobro
        PRIMARY KEY (id_unidad_cobro),

    CONSTRAINT UQ_UnidadCobro_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_UnidadCobro_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

CREATE TABLE dbo.TarifaRecurso
(
    id_tarifa INT IDENTITY(1,1) NOT NULL,
    id_recurso INT NOT NULL,
    id_unidad_cobro INT NOT NULL,
    valor_unitario DECIMAL(18,2) NOT NULL,
    vigencia_desde DATETIME2(0) NOT NULL,
    vigencia_hasta DATETIME2(0) NULL,

    CONSTRAINT PK_TarifaRecurso
        PRIMARY KEY (id_tarifa),

    CONSTRAINT FK_TarifaRecurso_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso (id_recurso),

    CONSTRAINT FK_TarifaRecurso_UnidadCobro
        FOREIGN KEY (id_unidad_cobro)
        REFERENCES dbo.UnidadCobro (id_unidad_cobro),

    CONSTRAINT UQ_TarifaRecurso_inicio
        UNIQUE (id_recurso, id_unidad_cobro, vigencia_desde),

    CONSTRAINT CK_TarifaRecurso_valor
        CHECK (valor_unitario > 0),

    CONSTRAINT CK_TarifaRecurso_vigencia
        CHECK (
            vigencia_hasta IS NULL
            OR vigencia_hasta > vigencia_desde
        )
);
GO

CREATE TABLE dbo.Bodega
(
    id_bodega INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(150) NOT NULL,
    direccion NVARCHAR(250) NOT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_Bodega_activo DEFAULT 1,

    CONSTRAINT PK_Bodega
        PRIMARY KEY (id_bodega),

    CONSTRAINT CK_Bodega_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_Bodega_direccion
        CHECK (LEN(LTRIM(RTRIM(direccion))) > 0)
);
GO

CREATE TABLE dbo.CondicionMaterial
(
    id_condicion INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    permite_despacho BIT NOT NULL,

    CONSTRAINT PK_CondicionMaterial
        PRIMARY KEY (id_condicion),

    CONSTRAINT UQ_CondicionMaterial_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_CondicionMaterial_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

CREATE TABLE dbo.TipoMovimiento
(
    id_tipo_movimiento INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NOT NULL,

    CONSTRAINT PK_TipoMovimiento
        PRIMARY KEY (id_tipo_movimiento),

    CONSTRAINT UQ_TipoMovimiento_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_TipoMovimiento_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_TipoMovimiento_descripcion
        CHECK (LEN(LTRIM(RTRIM(descripcion))) > 0)
);
GO
