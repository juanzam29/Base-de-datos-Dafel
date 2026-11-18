USE DaferDB;
GO

CREATE TABLE dbo.Obra
(
    id_obra INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(150) NOT NULL,
    direccion NVARCHAR(250) NOT NULL,
    ciudad NVARCHAR(100) NOT NULL,
    indicaciones_acceso NVARCHAR(500) NULL,

    CONSTRAINT PK_Obra
        PRIMARY KEY (id_obra),

    CONSTRAINT CK_Obra_nombre
        CHECK (LEN(LTRIM(RTRIM(nombre))) > 0),

    CONSTRAINT CK_Obra_direccion
        CHECK (LEN(LTRIM(RTRIM(direccion))) > 0),

    CONSTRAINT CK_Obra_ciudad
        CHECK (LEN(LTRIM(RTRIM(ciudad))) > 0)
);
GO
