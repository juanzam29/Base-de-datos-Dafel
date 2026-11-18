USE [DafelDB];
GO

/*
CONSULTA 04 - ALQUILERES ACTIVOS
Objetivo: identificar alquileres vigentes, cantidades pendientes de devolucion
y dias de retraso.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    estado_operativo,
    fecha_confirmacion,
    razon_social,
    obra,
    ciudad,
    codigo,
    recurso,
    naturaleza,
    cantidad,
    fecha_inicio,
    fecha_fin,
    despachada,
    devuelta,
    pendiente_devolucion,
    dias_retraso,
    ultima_devolucion
FROM bi.vw_04_AlquileresActivos
ORDER BY dias_retraso DESC, numero_alquiler, codigo;

SELECT
    estado_operativo,
    COUNT(DISTINCT id_alquiler) AS alquileres,
    SUM(despachada) AS unidades_despachadas,
    SUM(devuelta) AS unidades_devueltas,
    SUM(pendiente_devolucion) AS pendiente_devolucion,
    MAX(dias_retraso) AS mayor_retraso_dias
FROM bi.vw_04_AlquileresActivos
GROUP BY estado_operativo
ORDER BY mayor_retraso_dias DESC, estado_operativo;
GO
