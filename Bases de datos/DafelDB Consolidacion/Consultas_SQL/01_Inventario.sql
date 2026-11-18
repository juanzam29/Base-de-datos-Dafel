USE [DafelDB];
GO

/*
CONSULTA 01 - INVENTARIO
Objetivo: calcular la disponibilidad estimada por recurso y bodega despues de
descontar material no apto, reservas pendientes y unidades en clientes.
*/
SET NOCOUNT ON;

-- Detalle verificable.
SELECT
    codigo,
    recurso,
    naturaleza,
    categoria,
    bodega,
    cantidad_fisica,
    apto_en_bodega,
    no_apto_en_bodega,
    reservado_pendiente_despacho,
    en_cliente,
    disponible_estimado,
    fecha_corte
FROM bi.vw_01_Inventario
ORDER BY categoria, codigo, bodega;

-- Resumen usado para lectura gerencial y Power BI.
SELECT
    categoria,
    SUM(cantidad_fisica) AS cantidad_fisica,
    SUM(apto_en_bodega) AS apto_en_bodega,
    SUM(no_apto_en_bodega) AS no_apto_en_bodega,
    SUM(reservado_pendiente_despacho) AS reservado,
    SUM(en_cliente) AS en_cliente,
    SUM(disponible_estimado) AS disponible_estimado
FROM bi.vw_01_Inventario
GROUP BY categoria
ORDER BY categoria;
GO

