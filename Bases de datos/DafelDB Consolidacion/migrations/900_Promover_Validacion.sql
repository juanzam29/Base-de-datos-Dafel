USE [master];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF DB_ID(N'DafelDB') IS NULL
    THROW 55900,'No existe la base anterior DafelDB.',1;
IF DB_ID(N'DafelDB_Validacion') IS NULL
    THROW 55901,'No existe DafelDB_Validacion.',1;
IF DB_ID(N'DafelDB_Legacy_20261116') IS NOT NULL
    THROW 55902,'DafelDB_Legacy_20261116 ya existe; no se repite la promocion.',1;

IF (SELECT COUNT(*) FROM DafelDB.sys.tables WHERE is_ms_shipped=0)<>43
    THROW 55903,'La base anterior no coincide con la linea base de 43 tablas.',1;
IF (SELECT COUNT(*) FROM DafelDB_Validacion.sys.tables WHERE is_ms_shipped=0)<>68
    THROW 55904,'La base de validacion no contiene las 68 tablas esperadas.',1;
IF EXISTS(SELECT 1 FROM DafelDB_Validacion.sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 55905,'La base de validacion tiene relaciones deshabilitadas o no confiables.',1;
IF EXISTS(SELECT 1 FROM DafelDB_Validacion.sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 55906,'La base de validacion tiene CHECK deshabilitados o no confiables.',1;
GO

BACKUP DATABASE [DafelDB_Validacion]
TO DISK=N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\DafelDB_Consolidada_20261116.bak'
WITH INIT,CHECKSUM,STATS=10,NAME=N'DafelDB consolidada y validada';
GO

RESTORE VERIFYONLY
FROM DISK=N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\DafelDB_Consolidada_20261116.bak'
WITH CHECKSUM;
GO

ALTER DATABASE [DafelDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [DafelDB] MODIFY NAME=[DafelDB_Legacy_20261116];
ALTER DATABASE [DafelDB_Legacy_20261116] SET MULTI_USER;
GO

RESTORE DATABASE [DafelDB]
FROM DISK=N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup\DafelDB_Consolidada_20261116.bak'
WITH
    MOVE N'DafelDB_Validacion'
        TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DafelDB.mdf',
    MOVE N'DafelDB_Validacion_log'
        TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DafelDB_log.ldf',
    RECOVERY,
    STATS=10;
GO

ALTER DATABASE [DafelDB]
    MODIFY FILE(NAME=N'DafelDB_Validacion',NEWNAME=N'DafelDB');
ALTER DATABASE [DafelDB]
    MODIFY FILE(NAME=N'DafelDB_Validacion_log',NEWNAME=N'DafelDB_log');
ALTER DATABASE [DafelDB] SET AUTO_CLOSE OFF;
ALTER DATABASE [DafelDB] SET MULTI_USER;
GO

SELECT name,state_desc,compatibility_level,collation_name,recovery_model_desc
FROM sys.databases
WHERE name IN(N'DafelDB',N'DafelDB_Validacion',N'DafelDB_Legacy_20261116')
ORDER BY name;
GO
