USE [DafelDB];
GO

/*
CONSULTA 02 - DISPONIBILIDAD FUTURA
Objetivo: comparar cantidades comprometidas y despachadas para anticipar
necesidades de inventario en alquileres actuales y futuros.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    fecha_inicio,
    fecha_fin,
    estado,
    razon_social,
    obra,
    codigo,
    recurso,
    bodega,
    cantidad_comprometida,
    cantidad_despachada,
    compromiso_pendiente,
    stock_apto_actual,
    es_futura
FROM bi.vw_02_DisponibilidadFutura
ORDER BY fecha_inicio, numero_alquiler, codigo;

SELECT
    codigo,
    recurso,
    SUM(cantidad_comprometida) AS cantidad_comprometida,
    SUM(cantidad_despachada) AS cantidad_despachada,
    SUM(compromiso_pendiente) AS compromiso_pendiente,
    MAX(stock_apto_actual) AS stock_apto_actual,
    SUM(CASE WHEN es_futura = 1 THEN compromiso_pendiente ELSE 0 END) AS pendiente_futuro
FROM bi.vw_02_DisponibilidadFutura
GROUP BY codigo, recurso
ORDER BY compromiso_pendiente DESC, codigo;
GO

