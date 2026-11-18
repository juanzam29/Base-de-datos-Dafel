USE [DafelDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF (SELECT COUNT(*) FROM dbo.Empleado)<>8
    THROW 56500,'El escenario empresarial debe conservar exactamente ocho empleados.',1;

IF (SELECT COUNT(*) FROM dbo.Solicitud WHERE numero_solicitud LIKE 'SOL-BI-%')<>120
    THROW 56501,'La carga de solicitudes BI esta incompleta o duplicada.',1;

IF (SELECT COUNT(*) FROM dbo.Alquiler WHERE numero_alquiler LIKE 'ALQ-BI-%')<>94
    THROW 56502,'La carga de alquileres BI esta incompleta o duplicada.',1;

IF EXISTS(SELECT 1 FROM dbo.v_SaldoFisico WHERE cantidad<0)
    THROW 56503,'La carga produjo un saldo fisico negativo.',1;

IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
    THROW 56504,'Existen claves foraneas deshabilitadas o no confiables.',1;

IF NOT EXISTS(SELECT 1 FROM bi.vw_01_Inventario)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_02_DisponibilidadFutura)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_03_Cotizaciones)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_04_AlquileresActivos)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_05_DespachosDevoluciones)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_06_UtilizacionEquipos)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_07_Liquidacion)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_08_PagosSaldos)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_09_ValoresRecaudos)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_10_Incidencias)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_11_Inspecciones)
 OR NOT EXISTS(SELECT 1 FROM bi.vw_12_DemandaNoAtendida)
    THROW 56505,'Una o mas vistas de Power BI no devuelve datos.',1;

EXECUTE AS USER=N'lector_powerbi_test';
IF HAS_PERMS_BY_NAME(N'bi',N'SCHEMA',N'SELECT')<>1
BEGIN
    REVERT;
    THROW 56506,'El lector de Power BI no puede consultar el esquema bi.',1;
END;
IF HAS_PERMS_BY_NAME(N'dbo.Cliente',N'OBJECT',N'SELECT')=1
BEGIN
    REVERT;
    THROW 56507,'El lector de Power BI tiene acceso directo no esperado a dbo.',1;
END;
SELECT TOP(1) id_cotizacion FROM bi.vw_03_Cotizaciones;
REVERT;

SELECT
    (SELECT COUNT(*) FROM dbo.Empleado) empleados,
    (SELECT COUNT(*) FROM dbo.Cliente) clientes,
    (SELECT COUNT(*) FROM dbo.Obra) obras,
    (SELECT COUNT(*) FROM dbo.Solicitud) solicitudes,
    (SELECT COUNT(*) FROM dbo.Cotizacion) cotizaciones,
    (SELECT COUNT(*) FROM dbo.Alquiler) alquileres,
    (SELECT COUNT(*) FROM dbo.Pago) pagos,
    (SELECT COUNT(*) FROM dbo.IncidenciaAlquiler) incidencias;

SELECT
    COUNT(*) alquileres,
    SUM(total_vigente) valor_vigente,
    SUM(pagos_recibidos) pagos_registrados,
    SUM(saldo_pendiente) saldo_pendiente
FROM bi.vw_08_PagosSaldos;

PRINT N'VALIDACION POWER BI COMPLETADA SIN ERRORES';
GO
