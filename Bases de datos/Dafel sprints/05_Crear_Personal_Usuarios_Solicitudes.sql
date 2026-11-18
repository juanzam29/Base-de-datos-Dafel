USE DaferDB;
GO

CREATE TABLE dbo.Empleado
(
    id_empleado INT IDENTITY(1,1) NOT NULL,
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(30) NOT NULL,
    nombre NVARCHAR(200) NOT NULL,
    telefono VARCHAR(30) NOT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_Empleado_activo DEFAULT 1,

    CONSTRAINT PK_Empleado
        PRIMARY KEY (id_empleado),

    CONSTRAINT UQ_Empleado_documento
        UNIQUE (tipo_documento, numero_documento),

    CONSTRAINT CK_Empleado_tipo_documento
        CHECK (LEN(LTRIM(RTRIM(tipo_documento))) > 0),

    CONSTRAINT CK_Empleado_numero_documento
        CHECK (LEN(LTRIM(RTRIM(numero_documento))) > 0),

    CONSTRAINT CK_Empleado_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_Empleado_telefono
        CHECK (LEN(LTRIM(RTRIM(telefono))) > 0)
);
GO

CREATE TABLE dbo.Usuario
(
    id_usuario INT IDENTITY(1,1) NOT NULL,
    id_empleado INT NOT NULL,
    nombre_usuario NVARCHAR(100) NOT NULL,
    hash_contrasena VARCHAR(255) NOT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_Usuario_activo DEFAULT 1,

    CONSTRAINT PK_Usuario
        PRIMARY KEY (id_usuario),

    CONSTRAINT FK_Usuario_Empleado
        FOREIGN KEY (id_empleado)
        REFERENCES dbo.Empleado (id_empleado),

    CONSTRAINT UQ_Usuario_empleado
        UNIQUE (id_empleado),

    CONSTRAINT UQ_Usuario_nombre
        UNIQUE (nombre_usuario),

    CONSTRAINT CK_Usuario_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre_usuario))) > 0),

    CONSTRAINT CK_Usuario_hash
        CHECK (LEN(LTRIM(RTRIM(hash_contrasena))) > 0)
);
GO

CREATE TABLE dbo.Rol
(
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NOT NULL,

    CONSTRAINT PK_Rol
        PRIMARY KEY (id_rol),

    CONSTRAINT UQ_Rol_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_Rol_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_Rol_descripcion
        CHECK (LEN(LTRIM(RTRIM(descripcion))) > 0)
);
GO

CREATE TABLE dbo.UsuarioRol
(
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,

    CONSTRAINT PK_UsuarioRol
        PRIMARY KEY (id_usuario, id_rol),

    CONSTRAINT FK_UsuarioRol_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario (id_usuario),

    CONSTRAINT FK_UsuarioRol_Rol
        FOREIGN KEY (id_rol)
        REFERENCES dbo.Rol (id_rol)
);
GO

CREATE TABLE dbo.EmpleadoServicio
(
    id_empleado INT NOT NULL,
    id_recurso INT NOT NULL,

    CONSTRAINT PK_EmpleadoServicio
        PRIMARY KEY (id_empleado, id_recurso),

    CONSTRAINT FK_EmpleadoServicio_Empleado
        FOREIGN KEY (id_empleado)
        REFERENCES dbo.Empleado (id_empleado),

    CONSTRAINT FK_EmpleadoServicio_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso (id_recurso)
);
GO

CREATE TABLE dbo.Solicitud
(
    id_solicitud INT IDENTITY(1,1) NOT NULL,
    id_cliente INT NOT NULL,
    id_obra INT NOT NULL,
    numero_solicitud VARCHAR(30) NOT NULL,

    fecha_registro DATETIME2(0) NOT NULL
        CONSTRAINT DF_Solicitud_fecha DEFAULT SYSDATETIME(),

    canal VARCHAR(10) NOT NULL,

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Solicitud_estado DEFAULT 'RECIBIDA',

    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_Solicitud
        PRIMARY KEY (id_solicitud),

    CONSTRAINT FK_Solicitud_Cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dbo.Cliente (id_cliente),

    CONSTRAINT FK_Solicitud_Obra
        FOREIGN KEY (id_obra)
        REFERENCES dbo.Obra (id_obra),

    CONSTRAINT UQ_Solicitud_numero
        UNIQUE (numero_solicitud),

    CONSTRAINT CK_Solicitud_numero
        CHECK (LEN(LTRIM(RTRIM(numero_solicitud))) > 0),

    CONSTRAINT CK_Solicitud_canal
        CHECK (canal IN ('WEB', 'WHATSAPP')),

    CONSTRAINT CK_Solicitud_estado
        CHECK (
            estado IN (
                'RECIBIDA',
                'EN_REVISION',
                'EN_COTIZACION',
                'CONVERTIDA',
                'RECHAZADA',
                'CANCELADA',
                'VENCIDA'
            )
        )
);
GO

CREATE TABLE dbo.DetalleSolicitud
(
    id_detalle_solicitud INT IDENTITY(1,1) NOT NULL,
    id_solicitud INT NOT NULL,
    id_recurso INT NOT NULL,
    numero_linea INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_inicio_solicitada DATETIME2(0) NOT NULL,
    fecha_fin_solicitada DATETIME2(0) NOT NULL,

    CONSTRAINT PK_DetalleSolicitud
        PRIMARY KEY (id_detalle_solicitud),

    CONSTRAINT FK_DetalleSolicitud_Solicitud
        FOREIGN KEY (id_solicitud)
        REFERENCES dbo.Solicitud (id_solicitud),

    CONSTRAINT FK_DetalleSolicitud_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso (id_recurso),

    CONSTRAINT UQ_DetalleSolicitud_linea
        UNIQUE (id_solicitud, numero_linea),

    CONSTRAINT CK_DetalleSolicitud_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleSolicitud_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_DetalleSolicitud_periodo
        CHECK (fecha_fin_solicitada > fecha_inicio_solicitada)
);
GO