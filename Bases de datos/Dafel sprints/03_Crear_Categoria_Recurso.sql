USE DaferDB;
GO

CREATE TABLE dbo.Categoria
(
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(500) NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_Categoria_activo DEFAULT 1,

    CONSTRAINT PK_Categoria
        PRIMARY KEY (id_categoria),

    CONSTRAINT UQ_Categoria_nombre
        UNIQUE (nombre),

    CONSTRAINT CK_Categoria_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0)
);
GO

CREATE TABLE dbo.Recurso
(
    id_recurso INT IDENTITY(1,1) NOT NULL,
    id_categoria INT NOT NULL,
    codigo VARCHAR(30) NOT NULL,
    nombre NVARCHAR(150) NOT NULL,
    descripcion NVARCHAR(500) NULL,
    naturaleza VARCHAR(10) NOT NULL,

    activo BIT NOT NULL
        CONSTRAINT DF_Recurso_activo DEFAULT 1,

    CONSTRAINT PK_Recurso
        PRIMARY KEY (id_recurso),

    CONSTRAINT FK_Recurso_Categoria
        FOREIGN KEY (id_categoria)
        REFERENCES dbo.Categoria (id_categoria),

    CONSTRAINT UQ_Recurso_codigo
        UNIQUE (codigo),

    CONSTRAINT CK_Recurso_codigo
        CHECK (LEN(LTRIM(RTRIM(codigo))) > 0),

    CONSTRAINT CK_Recurso_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_Recurso_naturaleza
        CHECK (naturaleza IN ('EQUIPO', 'PERSONAL'))
);
GO