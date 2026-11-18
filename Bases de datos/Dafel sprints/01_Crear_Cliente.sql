USE master;
GO

CREATE DATABASE DaferDB;
GO

USE DaferDB;
GO

CREATE TABLE dbo.Cliente
(
    id_cliente INT IDENTITY(1,1) NOT NULL,
    nit VARCHAR(20) NOT NULL,
    razon_social NVARCHAR(200) NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    correo NVARCHAR(254) NULL,

    fecha_registro DATETIME2(0) NOT NULL
        CONSTRAINT DF_Cliente_fecha_registro
        DEFAULT SYSDATETIME(),

    activo BIT NOT NULL
        CONSTRAINT DF_Cliente_activo
        DEFAULT 1,

    CONSTRAINT PK_Cliente
        PRIMARY KEY (id_cliente),

    CONSTRAINT UQ_Cliente_nit
        UNIQUE (nit),

    CONSTRAINT CK_Cliente_nit
        CHECK (LEN(LTRIM(RTRIM(nit))) > 0),

    CONSTRAINT CK_Cliente_razon_social
        CHECK (LEN(LTRIM(RTRIM(razon_social))) > 0),

    CONSTRAINT CK_Cliente_telefono
        CHECK (LEN(LTRIM(RTRIM(telefono))) > 0)
);
GO