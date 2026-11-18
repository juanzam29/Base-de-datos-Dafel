USE [DafelDB];
GO

/*
CONSULTA 10 - INCIDENCIAS
Objetivo: analizar material afectado, estado, costo estimado y cargos autorizados
por incidencia.
*/
SET NOCOUNT ON;

SELECT
    id_incidencia,
    numero_alquiler,
    razon_social,
    obra,
    codigo,
    recurso,
    tipo,
    cantidad_afectada,
    fecha_registro,
    descripcion,
    estado,
    resolucion,
    fecha_resolucion,
    costo_estimado,
    responsabilidad_acordada,
    fecha_evaluacion,
    cargo_autorizado
FROM bi.vw_10_Incidencias
ORDER BY fecha_registro DESC, id_incidencia DESC;

SELECT
    estado,
    tipo,
    COUNT(*) AS incidencias,
    SUM(cantidad_afectada) AS cantidad_afectada,
    SUM(costo_estimado) AS costo_estimado,
    SUM(cargo_autorizado) AS cargo_autorizado
FROM bi.vw_10_Incidencias
GROUP BY estado, tipo
ORDER BY cantidad_afectada DESC, estado, tipo;
GO

