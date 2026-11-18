USE DaferDB;
GO

-- 1. ALQUILER

CREATE TABLE dbo.Alquiler
(
    id_alquiler INT IDENTITY(1,1) NOT NULL,
    id_version INT NOT NULL,
    numero_alquiler VARCHAR(30) NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Alquiler_fecha
        DEFAULT SYSDATETIME(),

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Alquiler_estado
        DEFAULT 'PENDIENTE',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_Alquiler
        PRIMARY KEY (id_alquiler),

    CONSTRAINT FK_Alquiler_Version
        FOREIGN KEY (id_version)
        REFERENCES dbo.VersionCotizacion(id_version),

    CONSTRAINT UQ_Alquiler_Version
        UNIQUE (id_version),

    CONSTRAINT UQ_Alquiler_numero
        UNIQUE (numero_alquiler),

    CONSTRAINT CK_Alquiler_numero
        CHECK (
            LEN(LTRIM(RTRIM(numero_alquiler))) > 0
        ),

    CONSTRAINT CK_Alquiler_estado
        CHECK (estado IN (
            'PENDIENTE',
            'EN_EJECUCION',
            'FINALIZADO',
            'CANCELADO'
        ))
);
GO

-- 2. DETALLE DEL ALQUILER

CREATE TABLE dbo.DetalleAlquiler
(
    id_detalle_alquiler INT IDENTITY(1,1) NOT NULL,
    id_alquiler INT NOT NULL,
    id_detalle_cotizacion INT NOT NULL,
    id_recurso INT NOT NULL,
    id_unidad_cobro INT NOT NULL,

    numero_linea INT NOT NULL,
    cantidad INT NOT NULL,

    fecha_inicio DATETIME2(0) NOT NULL,
    fecha_fin DATETIME2(0) NOT NULL,

    unidades_cobro DECIMAL(12,2) NOT NULL,
    valor_unitario DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_DetalleAlquiler
        PRIMARY KEY (id_detalle_alquiler),

    CONSTRAINT FK_DetalleAlquiler_Alquiler
        FOREIGN KEY (id_alquiler)
        REFERENCES dbo.Alquiler(id_alquiler),

    CONSTRAINT FK_DetalleAlquiler_Cotizacion
        FOREIGN KEY (id_detalle_cotizacion)
        REFERENCES dbo.DetalleCotizacion(id_detalle_cotizacion),

    CONSTRAINT FK_DetalleAlquiler_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso(id_recurso),

    CONSTRAINT FK_DetalleAlquiler_Unidad
        FOREIGN KEY (id_unidad_cobro)
        REFERENCES dbo.UnidadCobro(id_unidad_cobro),

    CONSTRAINT UQ_DetalleAlquiler_linea
        UNIQUE (id_alquiler, numero_linea),

    CONSTRAINT UQ_DetalleAlquiler_Cotizacion
        UNIQUE (id_alquiler, id_detalle_cotizacion),

    CONSTRAINT CK_DetalleAlquiler_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleAlquiler_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_DetalleAlquiler_periodo
        CHECK (fecha_fin > fecha_inicio),

    CONSTRAINT CK_DetalleAlquiler_unidades
        CHECK (unidades_cobro > 0),

    CONSTRAINT CK_DetalleAlquiler_valor
        CHECK (valor_unitario > 0)
);
GO

-- 3. DESPACHO

CREATE TABLE dbo.Despacho
(
    id_despacho INT IDENTITY(1,1) NOT NULL,
    id_alquiler INT NOT NULL,
    id_bodega INT NOT NULL,
    id_usuario INT NOT NULL,

    numero_despacho VARCHAR(30) NOT NULL,

    fecha_programada DATETIME2(0) NOT NULL,
    fecha_salida DATETIME2(0) NULL,

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Despacho_estado
        DEFAULT 'PROGRAMADO',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_Despacho
        PRIMARY KEY (id_despacho),

    CONSTRAINT FK_Despacho_Alquiler
        FOREIGN KEY (id_alquiler)
        REFERENCES dbo.Alquiler(id_alquiler),

    CONSTRAINT FK_Despacho_Bodega
        FOREIGN KEY (id_bodega)
        REFERENCES dbo.Bodega(id_bodega),

    CONSTRAINT FK_Despacho_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT UQ_Despacho_numero
        UNIQUE (numero_despacho),

    CONSTRAINT CK_Despacho_numero
        CHECK (
            LEN(LTRIM(RTRIM(numero_despacho))) > 0
        ),

    CONSTRAINT CK_Despacho_estado
        CHECK (estado IN (
            'PROGRAMADO',
            'EN_TRANSITO',
            'ENTREGADO',
            'CANCELADO'
        ))
);
GO

-- 4. DETALLE DEL DESPACHO

CREATE TABLE dbo.DetalleDespacho
(
    id_detalle_despacho INT IDENTITY(1,1) NOT NULL,
    id_despacho INT NOT NULL,
    id_detalle_alquiler INT NOT NULL,
    numero_linea INT NOT NULL,
    cantidad INT NOT NULL,

    CONSTRAINT PK_DetalleDespacho
        PRIMARY KEY (id_detalle_despacho),

    CONSTRAINT FK_DetalleDespacho_Despacho
        FOREIGN KEY (id_despacho)
        REFERENCES dbo.Despacho(id_despacho),

    CONSTRAINT FK_DetalleDespacho_Alquiler
        FOREIGN KEY (id_detalle_alquiler)
        REFERENCES dbo.DetalleAlquiler(id_detalle_alquiler),

    CONSTRAINT UQ_DetalleDespacho_linea
        UNIQUE (id_despacho, numero_linea),

    CONSTRAINT UQ_DetalleDespacho_recurso
        UNIQUE (id_despacho, id_detalle_alquiler),

    CONSTRAINT CK_DetalleDespacho_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleDespacho_cantidad
        CHECK (cantidad > 0)
);
GO

-- 5. ENTREGA EFECTIVA EN OBRA

CREATE TABLE dbo.Entrega
(
    id_entrega INT IDENTITY(1,1) NOT NULL,
    id_despacho INT NOT NULL,
    id_usuario INT NOT NULL,

    fecha_entrega DATETIME2(0) NOT NULL
        CONSTRAINT DF_Entrega_fecha
        DEFAULT SYSDATETIME(),

    recibido_por NVARCHAR(200) NOT NULL,
    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_Entrega
        PRIMARY KEY (id_entrega),

    CONSTRAINT FK_Entrega_Despacho
        FOREIGN KEY (id_despacho)
        REFERENCES dbo.Despacho(id_despacho),

    CONSTRAINT FK_Entrega_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT CK_Entrega_receptor
        CHECK (
            LEN(LTRIM(RTRIM(recibido_por))) > 0
        )
);
GO

-- 6. DETALLE DE ENTREGA

CREATE TABLE dbo.DetalleEntrega
(
    id_detalle_entrega INT IDENTITY(1,1) NOT NULL,
    id_entrega INT NOT NULL,
    id_detalle_despacho INT NOT NULL,
    cantidad_recibida INT NOT NULL,

    CONSTRAINT PK_DetalleEntrega
        PRIMARY KEY (id_detalle_entrega),

    CONSTRAINT FK_DetalleEntrega_Entrega
        FOREIGN KEY (id_entrega)
        REFERENCES dbo.Entrega(id_entrega),

    CONSTRAINT FK_DetalleEntrega_Despacho
        FOREIGN KEY (id_detalle_despacho)
        REFERENCES dbo.DetalleDespacho(id_detalle_despacho),

    CONSTRAINT UQ_DetalleEntrega_linea
        UNIQUE (id_entrega, id_detalle_despacho),

    CONSTRAINT CK_DetalleEntrega_cantidad
        CHECK (cantidad_recibida > 0)
);
GO

-- INDICES OPERATIVOS

CREATE INDEX IX_DetalleAlquiler_Recurso
ON dbo.DetalleAlquiler(id_recurso);
GO

CREATE INDEX IX_Despacho_Alquiler
ON dbo.Despacho(id_alquiler, estado);
GO

CREATE INDEX IX_Entrega_Despacho
ON dbo.Entrega(id_despacho);
GO