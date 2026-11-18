USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    ALTER TABLE dbo.ConceptoCotizacion
        ADD tipo_concepto VARCHAR(20) NOT NULL
            CONSTRAINT DF_ConceptoCotizacion_tipo DEFAULT 'OTRO' WITH VALUES;
    EXEC(N'ALTER TABLE dbo.ConceptoCotizacion WITH CHECK
        ADD CONSTRAINT CK_ConceptoCotizacion_tipo
        CHECK (tipo_concepto IN (''TRANSPORTE'',''MONTAJE'',''DESMONTAJE'',''OTRO''));');

    ALTER TABLE dbo.CargoAlquiler
        ADD tipo_cargo VARCHAR(20) NOT NULL
            CONSTRAINT DF_CargoAlquiler_tipo DEFAULT 'OTRO' WITH VALUES;
    EXEC(N'ALTER TABLE dbo.CargoAlquiler WITH CHECK
        ADD CONSTRAINT CK_CargoAlquiler_tipo
        CHECK (tipo_cargo IN (''RETRASO'',''DANO'',''FALTANTE'',''OTRO''));');

    ALTER TABLE dbo.Pago
        ADD tipo_pago VARCHAR(20) NOT NULL
            CONSTRAINT DF_Pago_tipo DEFAULT 'ABONO' WITH VALUES;
    EXEC(N'ALTER TABLE dbo.Pago WITH CHECK
        ADD CONSTRAINT CK_Pago_tipo
        CHECK (tipo_pago IN (''ANTICIPO'',''ABONO'',''SALDO''));');

    ALTER TABLE dbo.Alquiler
        ADD porcentaje_anticipo_requerido DECIMAL(5,2) NOT NULL
            CONSTRAINT DF_Alquiler_porcentaje_anticipo DEFAULT 100 WITH VALUES;
    EXEC(N'ALTER TABLE dbo.Alquiler WITH CHECK
        ADD CONSTRAINT CK_Alquiler_porcentaje_anticipo
        CHECK (porcentaje_anticipo_requerido BETWEEN 0 AND 100);');

    ALTER TABLE dbo.Documento ADD
        hash_sha256 VARBINARY(32) NULL,
        tamano_bytes BIGINT NULL;
    EXEC(N'ALTER TABLE dbo.Documento WITH CHECK
        ADD CONSTRAINT CK_Documento_tamano
        CHECK (tamano_bytes IS NULL OR tamano_bytes >= 0);');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

CREATE OR ALTER VIEW dbo.v_Liquidacion AS
SELECT
    a.id_alquiler,
    COALESCE(b.equipos,0) AS equipos,
    COALESCE(b.personal,0) AS personal,
    COALESCE(co.transporte,0) AS transporte,
    COALESCE(co.otros_conceptos,0) AS otros_conceptos,
    COALESCE(co.conceptos,0) AS conceptos_cotizacion,
    COALESCE(c.retrasos,0) AS retrasos,
    COALESCE(c.danos,0) AS danos,
    COALESCE(c.faltantes,0) AS faltantes,
    COALESCE(c.otros_cargos,0) AS otros_cargos,
    COALESCE(c.cargos,0) AS cargos_adicionales,
    COALESCE(j.ajustes,0) AS ajustes,
    COALESCE(b.equipos,0) + COALESCE(b.personal,0)
        + COALESCE(co.conceptos,0) + COALESCE(c.cargos,0)
        + COALESCE(j.ajustes,0) AS total_vigente,
    COALESCE(p.anticipos,0) AS anticipos,
    COALESCE(p.pagos,0) AS pagos_recibidos,
    COALESCE(re.efectivos,0) AS reembolsos_efectivos,
    COALESCE(re.pendientes,0) AS reembolsos_pendientes
FROM dbo.Alquiler a
OUTER APPLY
(
    SELECT
        SUM(CASE WHEN r.naturaleza='EQUIPO'
            THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) equipos,
        SUM(CASE WHEN r.naturaleza='PERSONAL'
            THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) personal
    FROM dbo.DetalleAlquiler da
    JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
    JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
    JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso
    WHERE da.id_alquiler=a.id_alquiler
) b
OUTER APPLY
(
    SELECT
        SUM(cantidad*valor_unitario) conceptos,
        SUM(CASE WHEN tipo_concepto='TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) transporte,
        SUM(CASE WHEN tipo_concepto<>'TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) otros_conceptos
    FROM dbo.ConceptoCotizacion
    WHERE id_cotizacion=a.id_cotizacion_aceptada
) co
OUTER APPLY
(
    SELECT
        SUM(importe) cargos,
        SUM(CASE WHEN tipo_cargo='RETRASO' THEN importe ELSE 0 END) retrasos,
        SUM(CASE WHEN tipo_cargo='DANO' THEN importe ELSE 0 END) danos,
        SUM(CASE WHEN tipo_cargo='FALTANTE' THEN importe ELSE 0 END) faltantes,
        SUM(CASE WHEN tipo_cargo='OTRO' THEN importe ELSE 0 END) otros_cargos
    FROM dbo.CargoAlquiler
    WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE'
) c
OUTER APPLY
(
    SELECT SUM(CASE WHEN tipo_ajuste='REDUCCION' THEN -importe ELSE importe END) ajustes
    FROM dbo.AjusteEconomicoAlquiler
    WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE'
) j
OUTER APPLY
(
    SELECT
        SUM(importe) pagos,
        SUM(CASE WHEN tipo_pago='ANTICIPO' THEN importe ELSE 0 END) anticipos
    FROM dbo.Pago
    WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE'
) p
OUTER APPLY
(
    SELECT
        SUM(CASE WHEN estado='EFECTUADO' THEN importe ELSE 0 END) efectivos,
        SUM(CASE WHEN estado='AUTORIZADO' THEN importe ELSE 0 END) pendientes
    FROM dbo.Reembolso
    WHERE id_alquiler=a.id_alquiler
) re;
GO

CREATE OR ALTER PROCEDURE reporte.usp_03_Cotizaciones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id_cotizacion,
        c.numero_version,
        s.numero_solicitud,
        cl.razon_social,
        o.nombre AS obra,
        c.estado,
        c.fecha_emision,
        c.fecha_vencimiento,
        c.motivo_rechazo,
        l.fecha_inicio,
        l.fecha_fin,
        CASE WHEN l.fecha_inicio IS NULL OR l.fecha_fin IS NULL THEN NULL
             ELSE CEILING(DATEDIFF_BIG(SECOND,l.fecha_inicio,l.fecha_fin)/86400.0) END AS bloques_24h_previstos,
        COALESCE(l.valor_recursos,0) AS valor_recursos,
        COALESCE(x.transporte,0) AS transporte,
        COALESCE(x.otros_conceptos,0) AS otros_conceptos,
        COALESCE(l.valor_recursos,0)+COALESCE(x.total_conceptos,0) AS valor_propuesta
    FROM dbo.Cotizacion c
    JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
    JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
    JOIN dbo.Obra o ON o.id_obra=s.id_obra
    OUTER APPLY
    (
        SELECT MIN(fecha_inicio) fecha_inicio, MAX(fecha_fin) fecha_fin,
               SUM(cantidad_ofrecida*tarifa_unitaria*unidades_tiempo_cobrables) valor_recursos
        FROM dbo.DetalleCotizacion
        WHERE id_cotizacion=c.id_cotizacion
    ) l
    OUTER APPLY
    (
        SELECT SUM(cantidad*valor_unitario) total_conceptos,
               SUM(CASE WHEN tipo_concepto='TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) transporte,
               SUM(CASE WHEN tipo_concepto<>'TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) otros_conceptos
        FROM dbo.ConceptoCotizacion
        WHERE id_cotizacion=c.id_cotizacion
    ) x;

    SELECT c.id_cotizacion,dc.numero_linea,r.nombre AS recurso,r.naturaleza,
           dc.cantidad_ofrecida,dc.fecha_inicio,dc.fecha_fin,
           dc.tarifa_unitaria,dc.unidades_tiempo_cobrables,
           dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables AS valor_linea
    FROM dbo.Cotizacion c
    JOIN dbo.DetalleCotizacion dc ON dc.id_cotizacion=c.id_cotizacion
    JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
    JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso;

    SELECT COUNT(*) solicitudes_cotizadas,
           SUM(CONVERT(INT,convertida)) solicitudes_convertidas,
           CAST(100.0*SUM(CONVERT(INT,convertida))/NULLIF(COUNT(*),0) AS DECIMAL(6,2)) porcentaje_conversion
    FROM
    (
        SELECT c.id_solicitud,
               CONVERT(BIT,MAX(CASE WHEN a.id_alquiler IS NULL THEN 0 ELSE 1 END)) convertida
        FROM dbo.Cotizacion c
        LEFT JOIN dbo.Alquiler a ON a.id_cotizacion_aceptada=c.id_cotizacion
        GROUP BY c.id_solicitud
    ) q;
END;
GO

CREATE OR ALTER PROCEDURE reporte.usp_07_Liquidacion
    @IdAlquiler INT=NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.numero_alquiler,l.*
    FROM dbo.v_Liquidacion l
    JOIN dbo.Alquiler a ON a.id_alquiler=l.id_alquiler
    WHERE @IdAlquiler IS NULL OR l.id_alquiler=@IdAlquiler;

    SELECT da.id_alquiler,r.nombre,r.naturaleza,dc.cantidad_ofrecida,
           dc.tarifa_unitaria,dc.unidades_tiempo_cobrables,
           dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables AS valor_inicial
    FROM dbo.DetalleAlquiler da
    JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
    JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
    JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso
    WHERE @IdAlquiler IS NULL OR da.id_alquiler=@IdAlquiler;

    SELECT id_alquiler,tipo_cargo,concepto,importe,justificacion,fecha_autorizacion
    FROM dbo.CargoAlquiler
    WHERE estado='VIGENTE' AND (@IdAlquiler IS NULL OR id_alquiler=@IdAlquiler);

    SELECT a.id_alquiler,co.tipo_concepto,co.concepto,co.descripcion,
           co.cantidad,co.valor_unitario,co.cantidad*co.valor_unitario importe
    FROM dbo.Alquiler a
    JOIN dbo.ConceptoCotizacion co ON co.id_cotizacion=a.id_cotizacion_aceptada
    WHERE @IdAlquiler IS NULL OR a.id_alquiler=@IdAlquiler;

    SELECT id_alquiler,tipo_ajuste,importe,motivo,estado,fecha_autorizacion
    FROM dbo.AjusteEconomicoAlquiler
    WHERE @IdAlquiler IS NULL OR id_alquiler=@IdAlquiler;
END;
GO

CREATE OR ALTER PROCEDURE reporte.usp_08_PagosSaldos
    @IdAlquiler INT=NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.numero_alquiler,cl.razon_social,l.total_vigente,l.anticipos,
           l.pagos_recibidos,l.reembolsos_efectivos,
           l.pagos_recibidos-l.reembolsos_efectivos AS pagos_netos,
           CASE WHEN l.total_vigente>l.pagos_recibidos-l.reembolsos_efectivos
                THEN l.total_vigente-(l.pagos_recibidos-l.reembolsos_efectivos) ELSE 0 END AS saldo_pendiente,
           CASE WHEN l.pagos_recibidos-l.reembolsos_efectivos>l.total_vigente
                THEN l.pagos_recibidos-l.reembolsos_efectivos-l.total_vigente ELSE 0 END AS excedente,
           l.reembolsos_pendientes
    FROM dbo.v_Liquidacion l
    JOIN dbo.Alquiler a ON a.id_alquiler=l.id_alquiler
    JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
    JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
    JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
    WHERE @IdAlquiler IS NULL OR l.id_alquiler=@IdAlquiler;

    SELECT id_pago,id_alquiler,tipo_pago,fecha_pago,importe,medio_pago,
           referencia_transaccion,estado
    FROM dbo.Pago
    WHERE @IdAlquiler IS NULL OR id_alquiler=@IdAlquiler;

    SELECT id_reembolso,id_alquiler,importe,estado,fecha_autorizacion,fecha_efectiva
    FROM dbo.Reembolso
    WHERE @IdAlquiler IS NULL OR id_alquiler=@IdAlquiler;
END;
GO

CREATE OR ALTER PROCEDURE reporte.usp_09_ValoresRecaudos
    @Inicio DATETIME2(0),
    @Fin DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    IF @Inicio IS NULL OR @Fin IS NULL OR @Fin<=@Inicio
        THROW 52002,'Periodo invalido.',1;

    SELECT cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,
           a.id_alquiler,a.numero_alquiler,l.equipos,l.personal,l.transporte,
           l.otros_conceptos,l.retrasos,l.danos,l.faltantes,l.otros_cargos,
           l.ajustes,l.total_vigente
    FROM dbo.Alquiler a
    JOIN dbo.v_Liquidacion l ON l.id_alquiler=a.id_alquiler
    JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
    JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
    JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
    JOIN dbo.Obra o ON o.id_obra=s.id_obra
    WHERE a.fecha_confirmacion>=@Inicio AND a.fecha_confirmacion<@Fin;

    ;WITH movimientos AS
    (
        SELECT id_alquiler,fecha_pago AS fecha,importe AS monto
        FROM dbo.Pago WHERE estado='VIGENTE'
        UNION ALL
        SELECT id_alquiler,fecha_efectiva,-importe
        FROM dbo.Reembolso WHERE estado='EFECTUADO'
    )
    SELECT cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,
           a.id_alquiler,a.numero_alquiler,
           SUM(CASE WHEN m.monto>0 THEN m.monto ELSE 0 END) AS pagos,
           SUM(CASE WHEN m.monto<0 THEN -m.monto ELSE 0 END) AS reembolsos,
           SUM(m.monto) AS recaudo_neto
    FROM movimientos m
    JOIN dbo.Alquiler a ON a.id_alquiler=m.id_alquiler
    JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
    JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
    JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
    JOIN dbo.Obra o ON o.id_obra=s.id_obra
    WHERE m.fecha>=@Inicio AND m.fecha<@Fin
    GROUP BY cl.id_cliente,cl.razon_social,o.id_obra,o.nombre,a.id_alquiler,a.numero_alquiler;
END;
GO
