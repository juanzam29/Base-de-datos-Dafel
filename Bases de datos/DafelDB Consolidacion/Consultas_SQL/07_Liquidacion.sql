USE [DafelDB];
GO

/*
CONSULTA 07 - LIQUIDACION
Objetivo: consolidar conceptos cotizados, cargos, ajustes, pagos y reembolsos
para obtener el valor vigente de cada alquiler.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    fecha_confirmacion,
    estado_operativo,
    razon_social,
    obra,
    ciudad,
    equipos,
    personal,
    transporte,
    otros_conceptos,
    conceptos_cotizacion,
    retrasos,
    danos,
    faltantes,
    otros_cargos,
    cargos_adicionales,
    ajustes,
    total_vigente,
    anticipos,
    pagos_recibidos,
    reembolsos_efectivos,
    reembolsos_pendientes
FROM bi.vw_07_Liquidacion
ORDER BY fecha_confirmacion DESC, numero_alquiler;

SELECT
    estado_operativo,
    COUNT(*) AS alquileres,
    SUM(conceptos_cotizacion) AS conceptos_cotizacion,
    SUM(cargos_adicionales) AS cargos_adicionales,
    SUM(ajustes) AS ajustes,
    SUM(total_vigente) AS total_vigente,
    SUM(pagos_recibidos) AS pagos_recibidos,
    SUM(reembolsos_efectivos) AS reembolsos_efectivos
FROM bi.vw_07_Liquidacion
GROUP BY estado_operativo
ORDER BY total_vigente DESC, estado_operativo;
GO

