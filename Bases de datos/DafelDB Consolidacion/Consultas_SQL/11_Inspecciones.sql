USE [DafelDB];
GO

/*
CONSULTA 11 - INSPECCIONES
Objetivo: separar material apto, danado o bloqueado despues de su recepcion e
inspeccion.
*/
SET NOCOUNT ON;

SELECT
    id_inspeccion,
    fecha_inspeccion,
    inspector,
    numero_alquiler,
    codigo,
    recurso,
    bodega,
    fecha_recepcion,
    cantidad_recibida,
    cantidad_revisada,
    condicion_resultante,
    habilitado,
    observaciones
FROM bi.vw_11_Inspecciones
ORDER BY fecha_inspeccion DESC, id_inspeccion DESC, codigo;

SELECT
    condicion_resultante,
    habilitado,
    COUNT(*) AS lineas_inspeccion,
    SUM(cantidad_recibida) AS cantidad_recibida,
    SUM(cantidad_revisada) AS cantidad_revisada
FROM bi.vw_11_Inspecciones
GROUP BY condicion_resultante, habilitado
ORDER BY cantidad_recibida DESC, condicion_resultante;
GO

