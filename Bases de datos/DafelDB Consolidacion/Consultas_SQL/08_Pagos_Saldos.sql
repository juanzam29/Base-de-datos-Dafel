USE [DafelDB];
GO

/*
CONSULTA 08 - PAGOS Y SALDOS
Objetivo: determinar pagos netos, saldos pendientes y excedentes por alquiler y
cliente para priorizar la cartera.
*/
SET NOCOUNT ON;

SELECT
    numero_alquiler,
    fecha_confirmacion,
    estado_operativo,
    razon_social,
    obra,
    ciudad,
    total_vigente,
    anticipos,
    pagos_recibidos,
    reembolsos_efectivos,
    pagos_netos,
    saldo_pendiente,
    excedente
FROM bi.vw_08_PagosSaldos
ORDER BY saldo_pendiente DESC, razon_social, numero_alquiler;

SELECT
    razon_social,
    COUNT(*) AS alquileres,
    SUM(total_vigente) AS total_vigente,
    SUM(pagos_netos) AS pagos_netos,
    SUM(saldo_pendiente) AS saldo_pendiente,
    SUM(excedente) AS excedente
FROM bi.vw_08_PagosSaldos
GROUP BY razon_social
ORDER BY saldo_pendiente DESC, razon_social;
GO
