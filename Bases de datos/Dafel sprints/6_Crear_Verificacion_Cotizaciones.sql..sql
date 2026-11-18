USE DaferDB;
GO

-- 1. HISTORIAL DE VERIFICACIONES

CREATE TABLE dbo.VerificacionSolicitud
(
    id_verificacion INT IDENTITY(1,1) NOT NULL,
    id_solicitud INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_verificacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Verificacion_fecha
        DEFAULT SYSDATETIME(),
    resultado VARCHAR(20) NOT NULL,
    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_VerificacionSolicitud
        PRIMARY KEY (id_verificacion),

    CONSTRAINT FK_Verificacion_Solicitud
        FOREIGN KEY (id_solicitud)
        REFERENCES dbo.Solicitud(id_solicitud),

    CONSTRAINT FK_Verificacion_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT CK_Verificacion_resultado
        CHECK (resultado IN
        ('APTA', 'NO_APTA', 'PENDIENTE'))
);
GO

-- 2. COTIZACION

CREATE TABLE dbo.Cotizacion
(
    id_cotizacion INT IDENTITY(1,1) NOT NULL,
    id_solicitud INT NOT NULL,
    numero_cotizacion VARCHAR(30) NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Cotizacion_fecha
        DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Cotizacion
        PRIMARY KEY (id_cotizacion),

    CONSTRAINT FK_Cotizacion_Solicitud
        FOREIGN KEY (id_solicitud)
        REFERENCES dbo.Solicitud(id_solicitud),

    CONSTRAINT UQ_Cotizacion_Solicitud
        UNIQUE (id_solicitud),

    CONSTRAINT UQ_Cotizacion_numero
        UNIQUE (numero_cotizacion),

    CONSTRAINT CK_Cotizacion_numero
        CHECK (
            LEN(LTRIM(RTRIM(numero_cotizacion))) > 0
        )
);
GO

-- 3. VERSIONES DE COTIZACION

CREATE TABLE dbo.VersionCotizacion
(
    id_version INT IDENTITY(1,1) NOT NULL,
    id_cotizacion INT NOT NULL,
    numero_version INT NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_VersionCotizacion_fecha
        DEFAULT SYSDATETIME(),

    fecha_vencimiento DATETIME2(0) NULL,

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_VersionCotizacion_estado
        DEFAULT 'BORRADOR',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_VersionCotizacion
        PRIMARY KEY (id_version),

    CONSTRAINT FK_VersionCotizacion_Cotizacion
        FOREIGN KEY (id_cotizacion)
        REFERENCES dbo.Cotizacion(id_cotizacion),

    CONSTRAINT UQ_VersionCotizacion_numero
        UNIQUE (id_cotizacion, numero_version),

    CONSTRAINT CK_VersionCotizacion_numero
        CHECK (numero_version > 0),

    CONSTRAINT CK_VersionCotizacion_estado
        CHECK (estado IN (
            'BORRADOR',
            'ENVIADA',
            'ACEPTADA',
            'RECHAZADA',
            'VENCIDA'
        )),

    CONSTRAINT CK_VersionCotizacion_vencimiento
        CHECK (
            fecha_vencimiento IS NULL
            OR fecha_vencimiento > fecha_creacion
        )
);
GO

-- 4. DETALLES DE CADA VERSION

CREATE TABLE dbo.DetalleCotizacion
(
    id_detalle_cotizacion INT IDENTITY(1,1) NOT NULL,
    id_version INT NOT NULL,
    id_detalle_solicitud INT NOT NULL,
    id_recurso INT NOT NULL,
    id_unidad_cobro INT NOT NULL,

    numero_linea INT NOT NULL,
    nombre_recurso NVARCHAR(150) NOT NULL,
    cantidad INT NOT NULL,

    fecha_inicio DATETIME2(0) NOT NULL,
    fecha_fin DATETIME2(0) NOT NULL,

    unidades_cobro DECIMAL(12,2) NOT NULL,
    valor_unitario DECIMAL(18,2) NOT NULL,

    CONSTRAINT PK_DetalleCotizacion
        PRIMARY KEY (id_detalle_cotizacion),

    CONSTRAINT FK_DetalleCotizacion_Version
        FOREIGN KEY (id_version)
        REFERENCES dbo.VersionCotizacion(id_version),

    CONSTRAINT FK_DetalleCotizacion_Solicitud
        FOREIGN KEY (id_detalle_solicitud)
        REFERENCES dbo.DetalleSolicitud(id_detalle_solicitud),

    CONSTRAINT FK_DetalleCotizacion_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso(id_recurso),

    CONSTRAINT FK_DetalleCotizacion_Unidad
        FOREIGN KEY (id_unidad_cobro)
        REFERENCES dbo.UnidadCobro(id_unidad_cobro),

    CONSTRAINT UQ_DetalleCotizacion_linea
        UNIQUE (id_version, numero_linea),

    CONSTRAINT CK_DetalleCotizacion_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleCotizacion_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_DetalleCotizacion_periodo
        CHECK (fecha_fin > fecha_inicio),

    CONSTRAINT CK_DetalleCotizacion_unidades
        CHECK (unidades_cobro > 0),

    CONSTRAINT CK_DetalleCotizacion_valor
        CHECK (valor_unitario > 0),

    CONSTRAINT CK_DetalleCotizacion_nombre
        CHECK (
            LEN(LTRIM(RTRIM(nombre_recurso))) > 0
        )
);
GO