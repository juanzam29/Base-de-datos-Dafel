USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
GO

PRINT N'REPORTE 01';
EXEC reporte.usp_01_Inventario @Fecha='2026-11-19T12:00:00';

PRINT N'REPORTE 02';
EXEC reporte.usp_02_DisponibilidadFutura
    @Inicio='2026-11-17T08:00:00',
    @Fin='2026-11-20T08:00:00',
    @Cantidad=2;

PRINT N'REPORTE 03';
EXEC reporte.usp_03_Cotizaciones;

PRINT N'REPORTE 04';
EXEC reporte.usp_04_ActivosVencidos @Fecha='2026-11-20T12:00:00';

PRINT N'REPORTE 05';
EXEC reporte.usp_05_DespachosDevoluciones;

PRINT N'REPORTE 06';
EXEC reporte.usp_06_Utilizacion
    @Inicio='2026-11-01T00:00:00',
    @Fin='2026-11-16T14:00:00';

PRINT N'REPORTE 07';
EXEC reporte.usp_07_Liquidacion;

PRINT N'REPORTE 08';
EXEC reporte.usp_08_PagosSaldos;

PRINT N'REPORTE 09';
EXEC reporte.usp_09_ValoresRecaudos
    @Inicio='2026-11-01T00:00:00',
    @Fin='2026-12-01T00:00:00';

PRINT N'REPORTE 10';
EXEC reporte.usp_10_Incidencias;

PRINT N'REPORTE 11';
EXEC reporte.usp_11_InspeccionesBloqueos;

PRINT N'REPORTE 12';
EXEC reporte.usp_12_DemandaNoAtendida
    @Inicio='2026-11-01T00:00:00',
    @Fin='2026-12-01T00:00:00';

PRINT N'12 REPORTES EJECUTADOS SIN ERROR';
GO
