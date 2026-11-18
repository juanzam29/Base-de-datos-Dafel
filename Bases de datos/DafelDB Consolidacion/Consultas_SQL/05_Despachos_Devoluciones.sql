USE [DafelDB];
GO

/*
CONSULTA 05 - DESPACHOS Y DEVOLUCIONES
Objetivo: comparar cantidades contratadas, despachadas y devueltas para detectar
pendientes operativos por alquiler, obra y recurso.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    estado_operativo,
    razon_social,
    obra,
    ciudad,
    codigo,
    recurso,
    contratada,
    despachada,
    devuelta,
    pendiente_despacho,
    pendiente_devolucion,
    primera_salida,
    ultima_devolucion
FROM bi.vw_05_DespachosDevoluciones
ORDER BY numero_alquiler, codigo;

SELECT
    estado_operativo,
    obra,
    COUNT(DISTINCT id_alquiler) AS alquileres,
    SUM(contratada) AS contratada,
    SUM(despachada) AS despachada,
    SUM(devuelta) AS devuelta,
    SUM(pendiente_despacho) AS pendiente_despacho,
    SUM(pendiente_devolucion) AS pendiente_devolucion
FROM bi.vw_05_DespachosDevoluciones
GROUP BY estado_operativo, obra
ORDER BY pendiente_despacho DESC, pendiente_devolucion DESC, obra;
GO

