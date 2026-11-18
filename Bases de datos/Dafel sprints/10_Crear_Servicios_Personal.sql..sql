USE DaferDB;
GO

-- 1. ASIGNACION DE PERSONAL

CREATE TABLE dbo.AsignacionPersonal
(
    id_asignacion INT IDENTITY(1,1) NOT NULL,
    id_detalle_alquiler INT NOT NULL,
    id_empleado INT NOT NULL,

    fecha_inicio DATETIME2(0) NOT NULL,
    fecha_fin DATETIME2(0) NOT NULL,

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_AsignacionPersonal_estado
        DEFAULT 'PROGRAMADA',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_AsignacionPersonal
        PRIMARY KEY (id_asignacion),

    CONSTRAINT FK_AsignacionPersonal_DetalleAlquiler
        FOREIGN KEY (id_detalle_alquiler)
        REFERENCES dbo.DetalleAlquiler(id_detalle_alquiler),

    CONSTRAINT FK_AsignacionPersonal_Empleado
        FOREIGN KEY (id_empleado)
        REFERENCES dbo.Empleado(id_empleado),

    CONSTRAINT CK_AsignacionPersonal_periodo
        CHECK (fecha_fin > fecha_inicio),

    CONSTRAINT CK_AsignacionPersonal_estado
        CHECK (estado IN (
            'PROGRAMADA',
            'ACTIVA',
            'FINALIZADA',
            'CANCELADA'
        ))
);
GO

-- 2. REGISTRO DE SERVICIOS PRESTADOS

CREATE TABLE dbo.RegistroServicio
(
    id_registro_servicio INT IDENTITY(1,1) NOT NULL,
    id_asignacion INT NOT NULL,

    fecha_inicio_real DATETIME2(0) NOT NULL,
    fecha_fin_real DATETIME2(0) NOT NULL,

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_RegistroServicio_estado
        DEFAULT 'REGISTRADO',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_RegistroServicio
        PRIMARY KEY (id_registro_servicio),

    CONSTRAINT FK_RegistroServicio_Asignacion
        FOREIGN KEY (id_asignacion)
        REFERENCES dbo.AsignacionPersonal(id_asignacion),

    CONSTRAINT CK_RegistroServicio_periodo
        CHECK (fecha_fin_real > fecha_inicio_real),

    CONSTRAINT CK_RegistroServicio_estado
        CHECK (estado IN (
            'REGISTRADO',
            'VALIDADO',
            'ANULADO'
        ))
);
GO

-- 3. CATALOGO DE NOVEDADES

CREATE TABLE dbo.TipoNovedadServicio
(
    id_tipo_novedad INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_TipoNovedadServicio_activo
        DEFAULT 1,

    CONSTRAINT PK_TipoNovedadServicio
        PRIMARY KEY (id_tipo_novedad),

    CONSTRAINT UQ_TipoNovedadServicio_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_TipoNovedadServicio_nombre
        CHECK (
            LEN(LTRIM(RTRIM(nombre))) > 0
        )
);
GO

-- 4. NOVEDADES DE SERVICIO

CREATE TABLE dbo.NovedadServicio
(
    id_novedad INT IDENTITY(1,1) NOT NULL,
    id_asignacion INT NOT NULL,
    id_tipo_novedad INT NOT NULL,
    id_usuario INT NOT NULL,

    fecha_novedad DATETIME2(0) NOT NULL
        CONSTRAINT DF_NovedadServicio_fecha
        DEFAULT SYSDATETIME(),

    descripcion NVARCHAR(1000) NOT NULL,

    CONSTRAINT PK_NovedadServicio
        PRIMARY KEY (id_novedad),

    CONSTRAINT FK_NovedadServicio_Asignacion
        FOREIGN KEY (id_asignacion)
        REFERENCES dbo.AsignacionPersonal(id_asignacion),

    CONSTRAINT FK_NovedadServicio_Tipo
        FOREIGN KEY (id_tipo_novedad)
        REFERENCES dbo.TipoNovedadServicio(id_tipo_novedad),

    CONSTRAINT FK_NovedadServicio_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario),

    CONSTRAINT CK_NovedadServicio_descripcion
        CHECK (
            LEN(LTRIM(RTRIM(descripcion))) > 0
        )
);
GO

-- 5. INDICES PARA CONSULTAS OPERATIVAS

CREATE INDEX IX_AsignacionPersonal_EmpleadoPeriodo
ON dbo.AsignacionPersonal
(id_empleado, fecha_inicio, fecha_fin)
INCLUDE (estado);
GO

CREATE INDEX IX_AsignacionPersonal_DetalleAlquiler
ON dbo.AsignacionPersonal(id_detalle_alquiler);
GO

CREATE INDEX IX_RegistroServicio_Asignacion
ON dbo.RegistroServicio(id_asignacion);
GO

CREATE INDEX IX_NovedadServicio_Asignacion
ON dbo.NovedadServicio(id_asignacion, fecha_novedad);
GO