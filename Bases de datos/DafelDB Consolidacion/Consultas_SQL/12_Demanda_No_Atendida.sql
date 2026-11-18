USE [DafelDB];
GO

/*
CONSULTA 12 - DEMANDA NO ATENDIDA
Objetivo: identificar recursos con faltantes, motivo de no atencion, alternativa
propuesta y decision del cliente.
*/
SET NOCOUNT ON;

SELECT
    fecha_evaluacion,
    es_ultima_evaluacion,
    numero_solicitud,
    estado_solicitud,
    razon_social,
    obra,
    codigo,
    recurso,
    naturaleza,
    cantidad_solicitada_evaluada,
    cantidad_disponible,
    faltante,
    fecha_inicio_evaluada,
    fecha_fin_evaluada,
    depende_de_devoluciones,
    motivo_no_atencion,
    alternativa_propuesta,
    decision_cliente,
    fecha_decision_cliente
FROM bi.vw_12_DemandaNoAtendida
ORDER BY fecha_evaluacion DESC, numero_solicitud, codigo;

SELECT
    codigo,
    recurso,
    motivo_no_atencion,
    COUNT(DISTINCT id_solicitud) AS solicitudes_afectadas,
    SUM(cantidad_solicitada_evaluada) AS cantidad_solicitada,
    SUM(cantidad_disponible) AS cantidad_disponible,
    SUM(faltante) AS cantidad_faltante,
    SUM(CASE WHEN depende_de_devoluciones = 1 THEN faltante ELSE 0 END) AS faltante_dependiente_devoluciones
FROM bi.vw_12_DemandaNoAtendida
GROUP BY codigo, recurso, motivo_no_atencion
ORDER BY cantidad_faltante DESC, codigo;
GO
