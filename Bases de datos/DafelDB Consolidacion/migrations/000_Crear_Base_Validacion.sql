USE [master];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF DB_ID(N'DafelDB_Validacion') IS NOT NULL
    THROW 55000, 'DafelDB_Validacion ya existe. No se reemplaza automaticamente.', 1;
GO

CREATE DATABASE [DafelDB_Validacion]
COLLATE Modern_Spanish_CI_AS;
GO

ALTER DATABASE [DafelDB_Validacion] SET COMPATIBILITY_LEVEL = 160;
ALTER DATABASE [DafelDB_Validacion] SET AUTO_CLOSE OFF;
ALTER DATABASE [DafelDB_Validacion] SET AUTO_SHRINK OFF;
ALTER DATABASE [DafelDB_Validacion] SET PAGE_VERIFY CHECKSUM;
ALTER DATABASE [DafelDB_Validacion] SET RECOVERY SIMPLE;
ALTER DATABASE [DafelDB_Validacion] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [DafelDB_Validacion] SET QUERY_STORE = ON;
GO

SELECT
    name,
    state_desc,
    compatibility_level,
    collation_name,
    recovery_model_desc,
    is_auto_close_on,
    is_read_committed_snapshot_on
FROM sys.databases
WHERE name = N'DafelDB_Validacion';
GO
