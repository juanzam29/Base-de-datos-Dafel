USE [DafelDB];
GO

/*
CONSULTA 03 - COTIZACIONES
Objetivo: analizar valor, estado y conversion de las cotizaciones emitidas.
*/
SET NOCOUNT ON;

SELECT
    id_cotizacion,
    numero_version,
    numero_solicitud,
    canal,
    razon_social,
    obra,
    ciudad,
    estado,
    fecha_emision,
    fecha_vencimiento,
    fecha_respuesta,
    motivo_rechazo,
    cantidad_lineas,
    duracion_dias,
    valor_equipos,
    valor_personal,
    transporte,
    otros_conceptos,
    valor_propuesta,
    convertida
FROM bi.vw_03_Cotizaciones
ORDER BY fecha_emision DESC, id_cotizacion DESC;

SELECT
    estado,
    COUNT(*) AS cotizaciones,
    SUM(valor_propuesta) AS valor_propuesto,
    SUM(CASE WHEN convertida = 1 THEN 1 ELSE 0 END) AS convertidas,
    CAST(100.0 * SUM(CASE WHEN convertida = 1 THEN 1 ELSE 0 END)
         / NULLIF(COUNT(*), 0) AS decimal(7,2)) AS porcentaje_conversion
FROM bi.vw_03_Cotizaciones
GROUP BY estado
ORDER BY valor_propuesto DESC;
GO

