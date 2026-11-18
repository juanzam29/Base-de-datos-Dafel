USE DaferDB;
GO

-- 1. DEVOLUCION

CREATE TABLE dbo.Devolucion
(
    id_devolucion INT IDENTITY(1,1) NOT NULL,
    id_alquiler INT NOT NULL,
    id_usuario INT NOT NULL,
    numero_devolucion VARCHAR(30) NOT NULL,

    fecha_devolucion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Devolucion_fecha
        DEFAULT SYSDATETIME(),

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Devolucion_estado
        DEFAULT 'REGISTRADA',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_Devolucion
        PRIMARY KEY (id_devolucion),

    CONSTRAINT FK_Devolucion_Alquiler
        FOREIGN KEY (id_alquiler)
        REFERENCES dbo.Alquiler(id_alquiler),

    CONSTRAINT FK_Devolucion_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT UQ_Devolucion_numero
        UNIQUE (numero_devolucion),

    CONSTRAINT CK_Devolucion_numero
        CHECK (
            LEN(LTRIM(RTRIM(numero_devolucion))) > 0
        ),

    CONSTRAINT CK_Devolucion_estado
        CHECK (estado IN (
            'REGISTRADA',
            'EN_INSPECCION',
            'PROCESADA',
            'ANULADA'
        ))
);
GO

-- 2. DETALLES DE DEVOLUCION

CREATE TABLE dbo.DetalleDevolucion
(
    id_detalle_devolucion INT IDENTITY(1,1) NOT NULL,
    id_devolucion INT NOT NULL,
    id_detalle_alquiler INT NOT NULL,
    numero_linea INT NOT NULL,
    cantidad_recibida INT NOT NULL,

    CONSTRAINT PK_DetalleDevolucion
        PRIMARY KEY (id_detalle_devolucion),

    CONSTRAINT FK_DetalleDevolucion_Devolucion
        FOREIGN KEY (id_devolucion)
        REFERENCES dbo.Devolucion(id_devolucion),

    CONSTRAINT FK_DetalleDevolucion_Alquiler
        FOREIGN KEY (id_detalle_alquiler)
        REFERENCES dbo.DetalleAlquiler(id_detalle_alquiler),

    CONSTRAINT UQ_DetalleDevolucion_linea
        UNIQUE (id_devolucion, numero_linea),

    CONSTRAINT UQ_DetalleDevolucion_recurso
        UNIQUE (id_devolucion, id_detalle_alquiler),

    CONSTRAINT CK_DetalleDevolucion_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleDevolucion_cantidad
        CHECK (cantidad_recibida > 0)
);
GO

-- 3. INSPECCION DE DEVOLUCION

CREATE TABLE dbo.InspeccionDevolucion
(
    id_inspeccion INT IDENTITY(1,1) NOT NULL,
    id_detalle_devolucion INT NOT NULL,
    id_usuario INT NOT NULL,

    fecha_inspeccion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Inspeccion_fecha
        DEFAULT SYSDATETIME(),

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Inspeccion_estado
        DEFAULT 'PENDIENTE',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_InspeccionDevolucion
        PRIMARY KEY (id_inspeccion),

    CONSTRAINT FK_Inspeccion_DetalleDevolucion
        FOREIGN KEY (id_detalle_devolucion)
        REFERENCES dbo.DetalleDevolucion(id_detalle_devolucion),

    CONSTRAINT FK_Inspeccion_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT UQ_Inspeccion_DetalleDevolucion
        UNIQUE (id_detalle_devolucion),

    CONSTRAINT CK_Inspeccion_estado
        CHECK (estado IN (
            'PENDIENTE',
            'COMPLETADA',
            'ANULADA'
        ))
);
GO

-- 4. RESULTADOS DE LA INSPECCION

CREATE TABLE dbo.DetalleInspeccion
(
    id_detalle_inspeccion INT IDENTITY(1,1) NOT NULL,
    id_inspeccion INT NOT NULL,
    id_condicion INT NOT NULL,
    cantidad INT NOT NULL,
    observaciones NVARCHAR(500) NULL,

    CONSTRAINT PK_DetalleInspeccion
        PRIMARY KEY (id_detalle_inspeccion),

    CONSTRAINT FK_DetalleInspeccion_Inspeccion
        FOREIGN KEY (id_inspeccion)
        REFERENCES dbo.InspeccionDevolucion(id_inspeccion),

    CONSTRAINT FK_DetalleInspeccion_Condicion
        FOREIGN KEY (id_condicion)
        REFERENCES dbo.CondicionMaterial(id_condicion),

    CONSTRAINT UQ_DetalleInspeccion_condicion
        UNIQUE (id_inspeccion, id_condicion),

    CONSTRAINT CK_DetalleInspeccion_cantidad
        CHECK (cantidad > 0)
);
GO

-- 5. CIERRE OPERATIVO DEL ALQUILER

CREATE TABLE dbo.CierreAlquiler
(
    id_cierre INT IDENTITY(1,1) NOT NULL,
    id_alquiler INT NOT NULL,
    id_usuario INT NOT NULL,

    fecha_cierre DATETIME2(0) NOT NULL
        CONSTRAINT DF_CierreAlquiler_fecha
        DEFAULT SYSDATETIME(),

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_CierreAlquiler_estado
        DEFAULT 'CERRADO',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_CierreAlquiler
        PRIMARY KEY (id_cierre),

    CONSTRAINT FK_CierreAlquiler_Alquiler
        FOREIGN KEY (id_alquiler)
        REFERENCES dbo.Alquiler(id_alquiler),

    CONSTRAINT FK_CierreAlquiler_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT UQ_CierreAlquiler_Alquiler
        UNIQUE (id_alquiler),

    CONSTRAINT CK_CierreAlquiler_estado
        CHECK (estado IN (
            'CERRADO',
            'CERRADO_CON_NOVEDADES'
        ))
);
GO

-- INDICES OPERATIVOS

CREATE INDEX IX_Devolucion_Alquiler
ON dbo.Devolucion(id_alquiler, estado);
GO

CREATE INDEX IX_DetalleDevolucion_Alquiler
ON dbo.DetalleDevolucion(id_detalle_alquiler);
GO

CREATE INDEX IX_InspeccionDevolucion_Estado
ON dbo.InspeccionDevolucion(estado);
GO