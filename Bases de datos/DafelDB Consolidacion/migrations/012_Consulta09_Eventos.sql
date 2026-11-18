USE DafelDB;
GO

/*
Consulta 09 - Valores aprobados y movimientos de recaudo.

Grano: una fila por evento financiero. La fecha analitica depende del evento:
  - APROBACION: fecha de confirmacion del alquiler.
  - CARGO_ADICIONAL: fecha de autorizacion del cargo vigente.
  - PAGO: fecha del pago vigente.
  - REEMBOLSO: fecha efectiva del reembolso efectuado.

Este diseno evita repetir el valor aprobado del alquiler por cada pago o cargo.
*/
CREATE OR ALTER VIEW bi.vw_09_ValoresRecaudosEventos
AS
WITH alquiler AS
(
    SELECT
        a.id_alquiler,
        a.numero_alquiler,
        a.fecha_confirmacion,
        cl.id_cliente,
        cl.razon_social,
        o.id_obra,
        o.nombre AS obra,
        o.ciudad,
        CONVERT(decimal(18,2), l.equipos) AS equipos,
        CONVERT(decimal(18,2), l.personal) AS personal,
        CONVERT(decimal(18,2), l.transporte) AS transporte
    FROM dbo.Alquiler AS a
    INNER JOIN dbo.v_Liquidacion AS l
        ON l.id_alquiler = a.id_alquiler
    INNER JOIN dbo.Cotizacion AS c
        ON c.id_cotizacion = a.id_cotizacion_aceptada
    INNER JOIN dbo.Solicitud AS s
        ON s.id_solicitud = c.id_solicitud
    INNER JOIN dbo.Cliente AS cl
        ON cl.id_cliente = s.id_cliente
    INNER JOIN dbo.Obra AS o
        ON o.id_obra = s.id_obra
)
SELECT
    CONVERT(varchar(30), CONCAT('APR-', a.id_alquiler)) AS id_evento,
    CONVERT(varchar(20), 'APROBACION') AS tipo_evento,
    a.fecha_confirmacion AS fecha_evento,
    DATEFROMPARTS(YEAR(a.fecha_confirmacion), MONTH(a.fecha_confirmacion), 1) AS periodo,
    a.id_alquiler,
    a.numero_alquiler,
    a.id_cliente,
    a.razon_social,
    a.id_obra,
    a.obra,
    a.ciudad,
    a.equipos AS valor_equipos,
    a.personal AS valor_personal,
    a.transporte AS valor_transporte,
    a.equipos + a.personal + a.transporte AS valor_aprobado_total,
    CONVERT(decimal(18,2), 0) AS cargos_adicionales,
    CONVERT(decimal(18,2), 0) AS pagos_recibidos,
    CONVERT(decimal(18,2), 0) AS reembolsos_efectuados,
    CONVERT(decimal(18,2), 0) AS recaudo_neto,
    a.equipos + a.personal + a.transporte AS monto_evento,
    CONVERT(nvarchar(250), 'Valores aprobados del alquiler') AS detalle_evento
FROM alquiler AS a

UNION ALL

SELECT
    CONVERT(varchar(30), CONCAT('CAR-', c.id_cargo)),
    CONVERT(varchar(20), 'CARGO_ADICIONAL'),
    c.fecha_autorizacion,
    DATEFROMPARTS(YEAR(c.fecha_autorizacion), MONTH(c.fecha_autorizacion), 1),
    a.id_alquiler,
    a.numero_alquiler,
    a.id_cliente,
    a.razon_social,
    a.id_obra,
    a.obra,
    a.ciudad,
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), c.importe),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), c.importe),
    CONVERT(nvarchar(250), CONCAT(c.tipo_cargo, ': ', c.concepto))
FROM dbo.CargoAlquiler AS c
INNER JOIN alquiler AS a
    ON a.id_alquiler = c.id_alquiler
WHERE c.estado = 'VIGENTE'

UNION ALL

SELECT
    CONVERT(varchar(30), CONCAT('PAG-', p.id_pago)),
    CONVERT(varchar(20), 'PAGO'),
    p.fecha_pago,
    DATEFROMPARTS(YEAR(p.fecha_pago), MONTH(p.fecha_pago), 1),
    a.id_alquiler,
    a.numero_alquiler,
    a.id_cliente,
    a.razon_social,
    a.id_obra,
    a.obra,
    a.ciudad,
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), p.importe),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), p.importe),
    CONVERT(decimal(18,2), p.importe),
    CONVERT(nvarchar(250), CONCAT(p.tipo_pago, ' / ', p.medio_pago, ' / ', p.referencia_transaccion))
FROM dbo.Pago AS p
INNER JOIN alquiler AS a
    ON a.id_alquiler = p.id_alquiler
WHERE p.estado = 'VIGENTE'

UNION ALL

SELECT
    CONVERT(varchar(30), CONCAT('REE-', r.id_reembolso)),
    CONVERT(varchar(20), 'REEMBOLSO'),
    r.fecha_efectiva,
    DATEFROMPARTS(YEAR(r.fecha_efectiva), MONTH(r.fecha_efectiva), 1),
    a.id_alquiler,
    a.numero_alquiler,
    a.id_cliente,
    a.razon_social,
    a.id_obra,
    a.obra,
    a.ciudad,
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), 0),
    CONVERT(decimal(18,2), r.importe),
    CONVERT(decimal(18,2), -r.importe),
    CONVERT(decimal(18,2), -r.importe),
    CONVERT(nvarchar(250), CONCAT(r.motivo, ' / ', r.referencia_transaccion))
FROM dbo.Reembolso AS r
INNER JOIN alquiler AS a
    ON a.id_alquiler = r.id_alquiler
WHERE r.estado = 'EFECTUADO'
  AND r.fecha_efectiva IS NOT NULL;
GO
