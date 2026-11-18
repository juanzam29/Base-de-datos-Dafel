USE DafelDB;
GO

/*
Consulta 09: valores aprobados y movimientos de recaudo.

Grano: una fila por evento financiero. La fecha usada para el periodo es la
fecha real de cada movimiento: confirmacion, autorizacion, pago o reembolso.
Esta es la fuente del archivo DafelDB_Dashboard_Consulta09.pbix.
*/
SELECT
    id_evento,
    tipo_evento,
    fecha_evento,
    periodo,
    id_alquiler,
    numero_alquiler,
    id_cliente,
    razon_social,
    id_obra,
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
GO
