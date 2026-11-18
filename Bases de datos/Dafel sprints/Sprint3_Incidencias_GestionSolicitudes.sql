
USE DaferDB;
GO

-- 1. DAÑOS, PERDIDAS Y DIFERENCIAS

IF OBJECT_ID('dbo.IncidenciaMaterial', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.IncidenciaMaterial
    (
        id_incidencia INT IDENTITY(1,1) PRIMARY KEY,
        id_detalle_devolucion INT NOT NULL,
        id_condicion INT NULL,
        id_usuario INT NOT NULL,
        tipo VARCHAR(20) NOT NULL,
        cantidad INT NOT NULL,
        costo_estimado DECIMAL(18,2) NULL,
        responsabilidad VARCHAR(20) NOT NULL
            DEFAULT 'PENDIENTE',
        resolucion NVARCHAR(1000) NULL,
        fecha_registro DATETIME2(0) NOT NULL
            DEFAULT SYSDATETIME(),

        CONSTRAINT FK_Incidencia_Devolucion
            FOREIGN KEY (id_detalle_devolucion)
            REFERENCES dbo.DetalleDevolucion(id_detalle_devolucion),

        CONSTRAINT FK_Incidencia_Condicion
            FOREIGN KEY (id_condicion)
            REFERENCES dbo.CondicionMaterial(id_condicion),

        CONSTRAINT FK_Incidencia_Usuario
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuario(id_usuario),

        CONSTRAINT CK_Incidencia_tipo
            CHECK (tipo IN (
                'DANO', 'PERDIDA', 'DIFERENCIA'
            )),

        CONSTRAINT CK_Incidencia_cantidad
            CHECK (cantidad > 0),

        CONSTRAINT CK_Incidencia_costo
            CHECK (costo_estimado IS NULL
                   OR costo_estimado >= 0),

        CONSTRAINT CK_Incidencia_responsabilidad
            CHECK (responsabilidad IN (
                'PENDIENTE',
                'CLIENTE',
                'DAFER',
                'COMPARTIDA',
                'SIN_RESPONSABLE'
            ))
    );
END;
GO

-- 2. EVIDENCIAS DE INCIDENCIAS

IF OBJECT_ID('dbo.EvidenciaIncidencia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.EvidenciaIncidencia
    (
        id_evidencia INT IDENTITY(1,1) PRIMARY KEY,
        id_incidencia INT NOT NULL,
        id_usuario INT NOT NULL,
        tipo VARCHAR(20) NOT NULL,
        ubicacion_archivo NVARCHAR(1000) NOT NULL,
        descripcion NVARCHAR(500) NULL,
        fecha_registro DATETIME2(0) NOT NULL
            DEFAULT SYSDATETIME(),

        CONSTRAINT FK_Evidencia_Incidencia
            FOREIGN KEY (id_incidencia)
            REFERENCES dbo.IncidenciaMaterial(id_incidencia),

        CONSTRAINT FK_Evidencia_Usuario
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuario(id_usuario),

        CONSTRAINT CK_Evidencia_tipo
            CHECK (tipo IN (
                'FOTO', 'DOCUMENTO', 'VIDEO', 'OTRO'
            )),

        CONSTRAINT CK_Evidencia_ubicacion
            CHECK (
                LEN(LTRIM(RTRIM(ubicacion_archivo))) > 0
            )
    );
END;
GO

-- 3. GESTION DE SOLICITUDES NO ATENDIDAS

IF OBJECT_ID('dbo.GestionSolicitud', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GestionSolicitud
    (
        id_gestion INT IDENTITY(1,1) PRIMARY KEY,
        id_detalle_solicitud INT NOT NULL,
        id_usuario INT NOT NULL,

        cantidad_disponible INT NOT NULL,
        motivo NVARCHAR(500) NOT NULL,
        alternativa NVARCHAR(1000) NULL,
        decision_cliente VARCHAR(20) NOT NULL
            DEFAULT 'PENDIENTE',

        fecha_gestion DATETIME2(0) NOT NULL
            DEFAULT SYSDATETIME(),

        CONSTRAINT FK_Gestion_DetalleSolicitud
            FOREIGN KEY (id_detalle_solicitud)
            REFERENCES dbo.DetalleSolicitud(id_detalle_solicitud),

        CONSTRAINT FK_Gestion_Usuario
            FOREIGN KEY (id_usuario)
            REFERENCES dbo.Usuario(id_usuario),

        CONSTRAINT CK_Gestion_cantidad
            CHECK (cantidad_disponible >= 0),

        CONSTRAINT CK_Gestion_motivo
            CHECK (LEN(LTRIM(RTRIM(motivo))) > 0),

        CONSTRAINT CK_Gestion_decision
            CHECK (decision_cliente IN (
                'PENDIENTE',
                'ACEPTADA',
                'RECHAZADA'
            ))
    );
END;
GO
