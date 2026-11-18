USE [DafelDB];
GO

SET NOCOUNT ON;
GO

PRINT 'CONSULTA 01 - INVENTARIO';
SELECT TOP (200) *
FROM bi.vw_01_Inventario
ORDER BY categoria, codigo, bodega;

PRINT 'CONSULTA 02 - DISPONIBILIDAD FUTURA';
SELECT TOP (200) *
FROM bi.vw_02_DisponibilidadFutura
ORDER BY fecha_inicio, numero_alquiler, codigo;

PRINT 'CONSULTA 03 - COTIZACIONES';
SELECT TOP (200) *
FROM bi.vw_03_Cotizaciones
ORDER BY fecha_emision DESC, id_cotizacion DESC;

PRINT 'CONSULTA 04 - ALQUILERES ACTIVOS';
SELECT TOP (200) *
FROM bi.vw_04_AlquileresActivos
ORDER BY dias_retraso DESC, numero_alquiler, codigo;

PRINT 'CONSULTA 05 - DESPACHOS Y DEVOLUCIONES';
SELECT TOP (200) *
FROM bi.vw_05_DespachosDevoluciones
ORDER BY numero_alquiler, codigo;

PRINT 'CONSULTA 06 - UTILIZACION DE EQUIPOS';
SELECT TOP (200) *
FROM bi.vw_06_UtilizacionEquipos
ORDER BY unidades_dia_alquiladas DESC, fecha_salida DESC;

PRINT 'CONSULTA 07 - LIQUIDACION';
SELECT TOP (200) *
FROM bi.vw_07_Liquidacion
ORDER BY fecha_confirmacion DESC, numero_alquiler;

PRINT 'CONSULTA 08 - PAGOS Y SALDOS';
SELECT TOP (200) *
FROM bi.vw_08_PagosSaldos
ORDER BY saldo_pendiente DESC, razon_social, numero_alquiler;

PRINT 'CONSULTA 09 - VALORES Y RECAUDOS POR EVENTO';
SELECT TOP (500) *
FROM bi.vw_09_ValoresRecaudosEventos
ORDER BY fecha_evento, id_evento;

PRINT 'CONSULTA 10 - INCIDENCIAS';
SELECT TOP (200) *
FROM bi.vw_10_Incidencias
ORDER BY fecha_registro DESC, id_incidencia DESC;

PRINT 'CONSULTA 11 - INSPECCIONES';
SELECT TOP (200) *
FROM bi.vw_11_Inspecciones
ORDER BY fecha_inspeccion DESC, id_inspeccion DESC;

PRINT 'CONSULTA 12 - DEMANDA NO ATENDIDA';
SELECT TOP (200) *
FROM bi.vw_12_DemandaNoAtendida
ORDER BY fecha_evaluacion DESC, numero_solicitud, codigo;

PRINT 'FIN: 12 CONSULTAS EJECUTADAS SOBRE DafelDB';
GO

