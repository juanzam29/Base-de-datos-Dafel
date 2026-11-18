USE DafelDB;
GO

/*
Consulta 09: valores contratados y recaudos por alquiler.
Esta es la fuente utilizada por DafelDB_Dashboard_Consulta09.pbix.
*/
SELECT
    id_alquiler,
    numero_alquiler,
    fecha_confirmacion,
    mes_confirmacion,
    id_cliente,
    razon_social,
    id_obra,
    obra,
    ciudad,
    equipos,
    personal,
    transporte,
    otros_conceptos,
    cargos_adicionales,
    ajustes,
    total_vigente,
    recaudo_bruto,
    reembolsos_efectivos,
    recaudo_neto,
    total_vigente - recaudo_neto AS saldo_por_recaudar,
    CASE
        WHEN total_vigente = 0 THEN 0
        ELSE recaudo_neto * 100.0 / total_vigente
    END AS porcentaje_recaudado
FROM bi.vw_09_ValoresRecaudos
ORDER BY fecha_confirmacion, numero_alquiler;
GO
