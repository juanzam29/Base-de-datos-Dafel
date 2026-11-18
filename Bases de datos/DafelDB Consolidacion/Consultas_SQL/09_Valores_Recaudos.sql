USE [DafelDB];
GO

/*
CONSULTA 09 - VALORES Y RECAUDOS POR EVENTO
Objetivo: sumar valores aprobados de equipos, personal y transporte; mantener
separados cargos, pagos y reembolsos; y calcular el recaudo neto segun la fecha
real de cada movimiento.

Grano: una fila por evento financiero para evitar duplicar valores aprobados
cuando un alquiler tiene varios pagos o cargos.
*/
SET NOCOUNT ON;

SELECT
    id_evento,
    tipo_evento,
    fecha_evento,
    periodo,
    numero_alquiler,
    razon_social,
    obra,
    ciudad,
    valor_equipos,
    valor_personal,
    valor_transporte,
    valor_aprobado_total,
    cargos_adicionales,
    pagos_recibidos,
    reembolsos_efectuados,
    recaudo_neto,
    monto_evento,
    detalle_evento
FROM bi.vw_09_ValoresRecaudosEventos
ORDER BY fecha_evento, id_evento;

-- Indicadores generales del dashboard.
SELECT
    COUNT(*) AS eventos,
    COUNT(DISTINCT id_alquiler) AS alquileres,
    COUNT(DISTINCT id_cliente) AS clientes,
    COUNT(DISTINCT id_obra) AS obras,
    SUM(valor_equipos) AS valor_equipos,
    SUM(valor_personal) AS valor_personal,
    SUM(valor_transporte) AS valor_transporte,
    SUM(valor_aprobado_total) AS valor_aprobado_total,
    SUM(cargos_adicionales) AS cargos_adicionales,
    SUM(pagos_recibidos) AS pagos_recibidos,
    SUM(reembolsos_efectuados) AS reembolsos_efectuados,
    SUM(recaudo_neto) AS recaudo_neto
FROM bi.vw_09_ValoresRecaudosEventos;

-- Tendencia mensual usada por Power BI.
SELECT
    periodo,
    SUM(valor_equipos) AS valor_equipos,
    SUM(valor_personal) AS valor_personal,
    SUM(valor_transporte) AS valor_transporte,
    SUM(cargos_adicionales) AS cargos_adicionales,
    SUM(pagos_recibidos) AS pagos_recibidos,
    SUM(reembolsos_efectuados) AS reembolsos_efectuados,
    SUM(recaudo_neto) AS recaudo_neto
FROM bi.vw_09_ValoresRecaudosEventos
GROUP BY periodo
ORDER BY periodo;
GO

