USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
GO

DECLARE @Impersonado BIT=0,@Visibles INT;

BEGIN TRY
    EXECUTE AS USER=N'prueba_sin_acceso';
    SET @Impersonado=1;

    SELECT @Visibles=COUNT(*) FROM sys.tables WHERE is_ms_shipped=0;
    IF @Visibles<>0 THROW 55400,'El usuario sin acceso ve tablas.',1;

    BEGIN TRY
        EXEC(N'SELECT TOP(0) id_cliente FROM dbo.Cliente;');
        THROW 55401,'El usuario sin acceso pudo leer Cliente.',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
    END CATCH;

    BEGIN TRY
        EXEC reporte.usp_01_Inventario;
        THROW 55402,'El usuario sin acceso pudo ejecutar un reporte.',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
    END CATCH;

    REVERT;
    SET @Impersonado=0;
    PRINT N'OK: usuario sin acceso restringido.';

    EXECUTE AS USER=N'prueba_reportes';
    SET @Impersonado=1;

    IF HAS_PERMS_BY_NAME(N'reporte.usp_01_Inventario',N'OBJECT',N'EXECUTE')<>1
        THROW 55403,'El usuario de reportes no tiene EXECUTE.',1;

    EXEC reporte.usp_01_Inventario @Fecha='2026-11-19T12:00:00';

    BEGIN TRY
        EXEC(N'SELECT TOP(0) id_usuario FROM dbo.Usuario;');
        THROW 55404,'El usuario de reportes pudo leer Usuario.',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
    END CATCH;

    REVERT;
    SET @Impersonado=0;
    PRINT N'OK: usuario de reportes limitado a procedimientos.';

    EXECUTE AS USER=N'prueba_auditoria';
    SET @Impersonado=1;

    SELECT TOP(1) id_auditoria,tabla,operacion,fecha
    FROM dbo.Auditoria ORDER BY id_auditoria DESC;

    BEGIN TRY
        EXEC(N'DELETE FROM dbo.Auditoria WHERE 1=0;');
        THROW 55405,'El auditor pudo modificar Auditoria.',1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()<>229 THROW;
    END CATCH;

    REVERT;
    SET @Impersonado=0;
    PRINT N'OK: auditor puede consultar y no modificar.';

    IF USER_NAME()<>N'dbo' THROW 55406,'No se recupero la identidad dbo.',1;
    PRINT N'PRUEBAS DE SEGURIDAD COMPLETADAS';
END TRY
BEGIN CATCH
    IF @Impersonado=1 REVERT;
    THROW;
END CATCH;
GO
