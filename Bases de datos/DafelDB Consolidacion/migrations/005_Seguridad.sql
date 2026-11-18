USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF DATABASE_PRINCIPAL_ID(N'dafel_reportes') IS NULL
        CREATE ROLE dafel_reportes AUTHORIZATION dbo;
    IF DATABASE_PRINCIPAL_ID(N'dafel_ventas') IS NULL
        CREATE ROLE dafel_ventas AUTHORIZATION dbo;
    IF DATABASE_PRINCIPAL_ID(N'dafel_auditoria') IS NULL
        CREATE ROLE dafel_auditoria AUTHORIZATION dbo;
    IF DATABASE_PRINCIPAL_ID(N'dafel_sin_acceso') IS NULL
        CREATE ROLE dafel_sin_acceso AUTHORIZATION dbo;

    IF DATABASE_PRINCIPAL_ID(N'prueba_reportes') IS NULL
        CREATE USER prueba_reportes WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID(N'prueba_ventas') IS NULL
        CREATE USER prueba_ventas WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID(N'prueba_auditoria') IS NULL
        CREATE USER prueba_auditoria WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID(N'prueba_sin_acceso') IS NULL
        CREATE USER prueba_sin_acceso WITHOUT LOGIN;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.database_role_members
        WHERE role_principal_id = DATABASE_PRINCIPAL_ID(N'dafel_reportes')
          AND member_principal_id = DATABASE_PRINCIPAL_ID(N'prueba_reportes')
    )
        ALTER ROLE dafel_reportes ADD MEMBER prueba_reportes;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.database_role_members
        WHERE role_principal_id = DATABASE_PRINCIPAL_ID(N'dafel_ventas')
          AND member_principal_id = DATABASE_PRINCIPAL_ID(N'prueba_ventas')
    )
        ALTER ROLE dafel_ventas ADD MEMBER prueba_ventas;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.database_role_members
        WHERE role_principal_id = DATABASE_PRINCIPAL_ID(N'dafel_auditoria')
          AND member_principal_id = DATABASE_PRINCIPAL_ID(N'prueba_auditoria')
    )
        ALTER ROLE dafel_auditoria ADD MEMBER prueba_auditoria;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.database_role_members
        WHERE role_principal_id = DATABASE_PRINCIPAL_ID(N'dafel_sin_acceso')
          AND member_principal_id = DATABASE_PRINCIPAL_ID(N'prueba_sin_acceso')
    )
        ALTER ROLE dafel_sin_acceso ADD MEMBER prueba_sin_acceso;

    REVOKE CONNECT FROM guest;

    GRANT EXECUTE ON OBJECT::operacion.usp_RegistrarCliente TO dafel_ventas;
    GRANT EXECUTE ON OBJECT::operacion.usp_RegistrarSolicitud TO dafel_ventas;

    GRANT EXECUTE ON OBJECT::reporte.usp_01_Inventario TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_02_DisponibilidadFutura TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_03_Cotizaciones TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_04_ActivosVencidos TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_05_DespachosDevoluciones TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_06_Utilizacion TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_07_Liquidacion TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_08_PagosSaldos TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_09_ValoresRecaudos TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_10_Incidencias TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_11_InspeccionesBloqueos TO dafel_reportes, dafel_ventas;
    GRANT EXECUTE ON OBJECT::reporte.usp_12_DemandaNoAtendida TO dafel_reportes, dafel_ventas;

    GRANT SELECT ON OBJECT::dbo.Auditoria TO dafel_auditoria;

    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO dafel_reportes;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO dafel_ventas;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO dafel_auditoria;

    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO dafel_sin_acceso;
    DENY VIEW DEFINITION TO dafel_sin_acceso;
    DENY EXECUTE ON SCHEMA::reporte TO dafel_sin_acceso;
    DENY EXECUTE ON SCHEMA::operacion TO dafel_sin_acceso;

    COMMIT TRANSACTION;
    PRINT N'SEGURIDAD CONFIGURADA';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
