USE [DafelDB];
GO

SET NOCOUNT ON;
GO

IF (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped=0)<>68
    THROW 55700,'Cantidad de tablas distinta de 68.',1;
IF (SELECT COUNT(*) FROM sys.foreign_keys)<>129
    THROW 55701,'Cantidad de relaciones distinta de 129.',1;
IF (SELECT COUNT(*) FROM sys.views WHERE is_ms_shipped=0)<>5
    THROW 55702,'Cantidad de vistas distinta de 5.',1;
IF (SELECT COUNT(*) FROM sys.procedures WHERE is_ms_shipped=0)<>23
    THROW 55703,'Cantidad de procedimientos distinta de 23.',1;
IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 55704,'Existen FK deshabilitadas o no confiables.',1;
IF EXISTS(SELECT 1 FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 55705,'Existen CHECK deshabilitados o no confiables.',1;
IF EXISTS(SELECT 1 FROM sys.objects WHERE name LIKE N'%Dafer%')
    THROW 55706,'Persisten objetos con el nombre Dafer.',1;
IF EXISTS(SELECT 1 FROM sys.sql_modules WHERE definition LIKE N'%Dafer%')
    THROW 55707,'Persisten modulos con el nombre Dafer.',1;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Alquiler a
    JOIN dbo.v_Liquidacion l ON l.id_alquiler=a.id_alquiler
    WHERE a.numero_alquiler='ALQ-DEMO-001'
      AND l.total_vigente=490000
      AND l.pagos_recibidos=440000
      AND l.total_vigente-(l.pagos_recibidos-l.reembolsos_efectivos)=50000
)
    THROW 55708,'La liquidacion de demostracion no coincide con 490000/440000/50000.',1;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.v_EntregaSaldo e
    JOIN dbo.DetalleDespacho dd ON dd.id_detalle_despacho=e.id_detalle_despacho
    JOIN dbo.Despacho d ON d.id_despacho=dd.id_despacho
    WHERE d.numero_despacho='DESP-DEMO-001'
      AND e.cantidad_despachada=2 AND e.cantidad_devuelta=1 AND e.pendiente=1
)
    THROW 55709,'La entrega parcial no coincide con 2/1/1.',1;

DBCC CHECKDB(N'DafelDB') WITH NO_INFOMSGS,ALL_ERRORMSGS;

SELECT
    DB_NAME() AS base_actual,
    (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped=0) AS tablas,
    (SELECT COUNT(*) FROM sys.foreign_keys) AS relaciones,
    (SELECT COUNT(*) FROM sys.views WHERE is_ms_shipped=0) AS vistas,
    (SELECT COUNT(*) FROM sys.procedures WHERE is_ms_shipped=0) AS procedimientos,
    (SELECT COUNT(*) FROM sys.triggers WHERE parent_class=1) AS triggers,
    (SELECT COUNT(*) FROM sys.extended_properties WHERE name=N'MS_Description') AS descripciones;

PRINT N'VALIDACION FINAL COMPLETADA';
GO
