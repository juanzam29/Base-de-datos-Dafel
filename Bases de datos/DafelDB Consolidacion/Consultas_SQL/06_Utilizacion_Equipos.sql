USE [DafelDB];
GO

/*
CONSULTA 06 - UTILIZACION DE EQUIPOS
Objetivo: medir la intensidad de uso mediante unidades-dia alquiladas.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    razon_social,
    obra,
    codigo,
    recurso,
    categoria,
    fecha_salida,
    ultima_devolucion,
    fecha_fin_uso,
    cantidad_despachada,
    cantidad_devuelta,
    pendiente,
    unidades_dia_alquiladas,
    mes_salida
FROM bi.vw_06_UtilizacionEquipos
ORDER BY unidades_dia_alquiladas DESC, fecha_salida DESC;

SELECT
    categoria,
    COUNT(DISTINCT id_alquiler) AS alquileres,
    SUM(cantidad_despachada) AS unidades_despachadas,
    SUM(cantidad_devuelta) AS unidades_devueltas,
    SUM(pendiente) AS unidades_pendientes,
    SUM(unidades_dia_alquiladas) AS unidades_dia_alquiladas
FROM bi.vw_06_UtilizacionEquipos
GROUP BY categoria
ORDER BY unidades_dia_alquiladas DESC, categoria;
GO

