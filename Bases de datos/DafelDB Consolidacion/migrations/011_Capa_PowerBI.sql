USE [DafelDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF SCHEMA_ID(N'bi') IS NULL EXEC(N'CREATE SCHEMA bi AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'bi.DimFecha',N'U') IS NULL
BEGIN
    CREATE TABLE bi.DimFecha
    (
        fecha DATE NOT NULL CONSTRAINT PK_bi_DimFecha PRIMARY KEY,
        anio SMALLINT NOT NULL,
        semestre TINYINT NOT NULL,
        trimestre TINYINT NOT NULL,
        numero_mes TINYINT NOT NULL,
        mes NVARCHAR(20) NOT NULL,
        anio_mes CHAR(7) NOT NULL,
        semana TINYINT NOT NULL,
        dia_mes TINYINT NOT NULL,
        dia_semana NVARCHAR(20) NOT NULL,
        es_fin_semana BIT NOT NULL
    );
END;
GO

;WITH fechas AS
(
    SELECT CONVERT(DATE,'2025-01-01') fecha
    UNION ALL
    SELECT DATEADD(DAY,1,fecha) FROM fechas WHERE fecha<'2027-12-31'
)
INSERT bi.DimFecha(fecha,anio,semestre,trimestre,numero_mes,mes,anio_mes,semana,dia_mes,dia_semana,es_fin_semana)
SELECT f.fecha,YEAR(f.fecha),CASE WHEN MONTH(f.fecha)<=6 THEN 1 ELSE 2 END,DATEPART(QUARTER,f.fecha),MONTH(f.fecha),
       CHOOSE(MONTH(f.fecha),N'Enero',N'Febrero',N'Marzo',N'Abril',N'Mayo',N'Junio',N'Julio',N'Agosto',N'Septiembre',N'Octubre',N'Noviembre',N'Diciembre'),
       CONVERT(CHAR(7),f.fecha,120),DATEPART(ISO_WEEK,f.fecha),DAY(f.fecha),
       CHOOSE(DATEPART(WEEKDAY,f.fecha),N'Domingo',N'Lunes',N'Martes',N'Miercoles',N'Jueves',N'Viernes',N'Sabado'),
       CONVERT(BIT,CASE WHEN DATEPART(WEEKDAY,f.fecha) IN(1,7) THEN 1 ELSE 0 END)
FROM fechas f
WHERE NOT EXISTS(SELECT 1 FROM bi.DimFecha d WHERE d.fecha=f.fecha)
OPTION(MAXRECURSION 0);
GO

CREATE OR ALTER VIEW bi.vw_DimCliente AS
SELECT id_cliente,nit,razon_social,telefono,correo,fecha_registro,activo
FROM dbo.Cliente;
GO

CREATE OR ALTER VIEW bi.vw_DimObra AS
SELECT id_obra,nombre AS obra,direccion,ciudad,indicaciones_acceso
FROM dbo.Obra;
GO

CREATE OR ALTER VIEW bi.vw_DimRecurso AS
SELECT r.id_recurso,r.codigo,r.nombre AS recurso,r.naturaleza,c.nombre AS categoria,r.activo
FROM dbo.Recurso r
JOIN dbo.Categoria c ON c.id_categoria=r.id_categoria;
GO

CREATE OR ALTER VIEW bi.vw_DimEmpleado AS
SELECT e.id_empleado,e.tipo_documento,e.numero_documento,e.nombre AS empleado,e.telefono,e.activo
FROM dbo.Empleado e;
GO

/* 01 - Inventario actual por recurso y bodega, en una sola tabla para Power BI. */
CREATE OR ALTER VIEW bi.vw_01_Inventario AS
WITH stock AS
(
    SELECT s.id_recurso,s.id_bodega,
           SUM(s.cantidad) cantidad_fisica,
           SUM(CASE WHEN c.permite_despacho=1 THEN s.cantidad ELSE 0 END) apto_en_bodega,
           SUM(CASE WHEN c.permite_despacho=0 THEN s.cantidad ELSE 0 END) no_apto_en_bodega
    FROM dbo.v_SaldoFisico s
    JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion
    GROUP BY s.id_recurso,s.id_bodega
), reservas AS
(
    SELECT ca.id_recurso,v.id_bodega,
           SUM(CASE WHEN v.estado='ACTIVA' AND v.fecha_inicio<=SYSDATETIME() AND v.fecha_fin>SYSDATETIME()
                    THEN CASE WHEN v.cantidad_comprometida>COALESCE(x.despachada,0)
                              THEN v.cantidad_comprometida-COALESCE(x.despachada,0) ELSE 0 END ELSE 0 END) reservado,
           SUM(COALESCE(x.en_cliente,0)) en_cliente
    FROM dbo.v_ReservaVigente v
    JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=v.id_detalle_alquiler
    OUTER APPLY
    (
        SELECT SUM(CONVERT(BIGINT,e.cantidad_despachada)) despachada,
               SUM(CONVERT(BIGINT,e.pendiente)) en_cliente
        FROM dbo.v_EntregaSaldo e WHERE e.id_reserva=v.id_reserva
    ) x
    GROUP BY ca.id_recurso,v.id_bodega
), claves AS
(
    SELECT id_recurso,id_bodega FROM stock
    UNION
    SELECT id_recurso,id_bodega FROM reservas
)
SELECT k.id_recurso,r.codigo,r.nombre AS recurso,r.naturaleza,c.nombre AS categoria,
       k.id_bodega,b.nombre AS bodega,
       COALESCE(s.cantidad_fisica,0) cantidad_fisica,
       COALESCE(s.apto_en_bodega,0) apto_en_bodega,
       COALESCE(s.no_apto_en_bodega,0) no_apto_en_bodega,
       COALESCE(rv.reservado,0) reservado_pendiente_despacho,
       COALESCE(rv.en_cliente,0) en_cliente,
       CASE WHEN COALESCE(s.apto_en_bodega,0)>COALESCE(rv.reservado,0)
            THEN COALESCE(s.apto_en_bodega,0)-COALESCE(rv.reservado,0) ELSE 0 END disponible_estimado,
       CONVERT(DATE,SYSDATETIME()) fecha_corte
FROM claves k
JOIN dbo.Recurso r ON r.id_recurso=k.id_recurso
JOIN dbo.Categoria c ON c.id_categoria=r.id_categoria
JOIN dbo.Bodega b ON b.id_bodega=k.id_bodega
LEFT JOIN stock s ON s.id_recurso=k.id_recurso AND s.id_bodega=k.id_bodega
LEFT JOIN reservas rv ON rv.id_recurso=k.id_recurso AND rv.id_bodega=k.id_bodega;
GO

/* 02 - Reservas futuras y capacidad actualmente comprometida. */
CREATE OR ALTER VIEW bi.vw_02_DisponibilidadFutura AS
WITH aptos AS
(
    SELECT s.id_recurso,SUM(s.cantidad) stock_apto
    FROM dbo.v_SaldoFisico s JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion
    WHERE c.permite_despacho=1 GROUP BY s.id_recurso
)
SELECT v.id_reserva,ca.id_alquiler,a.numero_alquiler,ca.id_recurso,r.codigo,r.nombre AS recurso,
       v.id_bodega,b.nombre AS bodega,v.cantidad_comprometida,
       COALESCE(x.despachada,0) cantidad_despachada,
       CASE WHEN v.cantidad_comprometida>COALESCE(x.despachada,0)
            THEN v.cantidad_comprometida-COALESCE(x.despachada,0) ELSE 0 END compromiso_pendiente,
       v.fecha_inicio,v.fecha_fin,v.estado,COALESCE(ap.stock_apto,0) stock_apto_actual,
       cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,
       CONVERT(BIT,CASE WHEN v.fecha_inicio>SYSDATETIME() THEN 1 ELSE 0 END) es_futura
FROM dbo.v_ReservaVigente v
JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=v.id_detalle_alquiler
JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
JOIN dbo.Cotizacion co ON co.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=co.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
JOIN dbo.Bodega b ON b.id_bodega=v.id_bodega
LEFT JOIN aptos ap ON ap.id_recurso=ca.id_recurso
OUTER APPLY(SELECT SUM(CONVERT(BIGINT,cantidad_despachada)) despachada FROM dbo.DetalleDespacho WHERE id_reserva=v.id_reserva)x
WHERE r.naturaleza='EQUIPO';
GO

/* 03 - Una fila por cotizacion, sin conjuntos de resultados adicionales. */
CREATE OR ALTER VIEW bi.vw_03_Cotizaciones AS
WITH lineas AS
(
    SELECT dc.id_cotizacion,COUNT(*) cantidad_lineas,MIN(dc.fecha_inicio) fecha_inicio,MAX(dc.fecha_fin) fecha_fin,
           SUM(CASE WHEN r.naturaleza='EQUIPO' THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) valor_equipos,
           SUM(CASE WHEN r.naturaleza='PERSONAL' THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) valor_personal
    FROM dbo.DetalleCotizacion dc
    JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
    JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso
    GROUP BY dc.id_cotizacion
), conceptos AS
(
    SELECT id_cotizacion,
           SUM(CASE WHEN tipo_concepto='TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) transporte,
           SUM(CASE WHEN tipo_concepto<>'TRANSPORTE' THEN cantidad*valor_unitario ELSE 0 END) otros_conceptos
    FROM dbo.ConceptoCotizacion GROUP BY id_cotizacion
)
SELECT c.id_cotizacion,c.numero_version,s.id_solicitud,s.numero_solicitud,s.canal,
       cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,o.ciudad,
       c.estado,c.fecha_emision,c.fecha_vencimiento,c.fecha_respuesta,c.motivo_rechazo,
       COALESCE(l.cantidad_lineas,0) cantidad_lineas,l.fecha_inicio,l.fecha_fin,
       DATEDIFF(DAY,l.fecha_inicio,l.fecha_fin) duracion_dias,
       COALESCE(l.valor_equipos,0) valor_equipos,COALESCE(l.valor_personal,0) valor_personal,
       COALESCE(x.transporte,0) transporte,COALESCE(x.otros_conceptos,0) otros_conceptos,
       COALESCE(l.valor_equipos,0)+COALESCE(l.valor_personal,0)+COALESCE(x.transporte,0)+COALESCE(x.otros_conceptos,0) valor_propuesta,
       CONVERT(BIT,CASE WHEN a.id_alquiler IS NULL THEN 0 ELSE 1 END) convertida
FROM dbo.Cotizacion c
JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
LEFT JOIN lineas l ON l.id_cotizacion=c.id_cotizacion
LEFT JOIN conceptos x ON x.id_cotizacion=c.id_cotizacion
LEFT JOIN dbo.Alquiler a ON a.id_cotizacion_aceptada=c.id_cotizacion;
GO

/* 04 - Condiciones vigentes, retraso y estado de cada linea alquilada. */
CREATE OR ALTER VIEW bi.vw_04_AlquileresActivos AS
SELECT a.id_alquiler,a.numero_alquiler,a.estado_operativo,a.fecha_confirmacion,
       cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,o.ciudad,
       ca.id_detalle_alquiler,ca.id_recurso,r.codigo,r.nombre AS recurso,r.naturaleza,
       ca.cantidad,ca.fecha_inicio,ca.fecha_fin,
       COALESCE(x.despachada,0) despachada,COALESCE(x.devuelta,0) devuelta,COALESCE(x.pendiente,0) pendiente_devolucion,
       CASE WHEN r.naturaleza='EQUIPO' AND COALESCE(x.pendiente,0)>0 AND SYSDATETIME()>ca.fecha_fin
            THEN CEILING(DATEDIFF_BIG(SECOND,ca.fecha_fin,SYSDATETIME())/86400.0)
            WHEN r.naturaleza='EQUIPO' AND x.ultima_devolucion>ca.fecha_fin
            THEN CEILING(DATEDIFF_BIG(SECOND,ca.fecha_fin,x.ultima_devolucion)/86400.0)
            ELSE 0 END dias_retraso,
       x.ultima_devolucion
FROM dbo.v_CondicionVigenteAlquiler ca
JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
OUTER APPLY
(
    SELECT SUM(CONVERT(BIGINT,e.cantidad_despachada)) despachada,
           SUM(CONVERT(BIGINT,e.cantidad_devuelta)) devuelta,
           SUM(CONVERT(BIGINT,e.pendiente)) pendiente,
           MAX(e.ultima_devolucion) ultima_devolucion
    FROM dbo.ReservaEquipo re JOIN dbo.v_EntregaSaldo e ON e.id_reserva=re.id_reserva
    WHERE re.id_detalle_alquiler=ca.id_detalle_alquiler
) x;
GO

/* 05 - Control de despachos y devoluciones por obra. */
CREATE OR ALTER VIEW bi.vw_05_DespachosDevoluciones AS
SELECT a.id_alquiler,a.numero_alquiler,a.estado_operativo,cl.id_cliente,cl.razon_social,
       o.id_obra,o.nombre AS obra,o.ciudad,ca.id_detalle_alquiler,ca.id_recurso,r.codigo,r.nombre AS recurso,
       ca.cantidad AS contratada,COALESCE(x.despachada,0) despachada,COALESCE(x.devuelta,0) devuelta,
       COALESCE(x.pendiente,0) pendiente_devolucion,
       CASE WHEN ca.cantidad>COALESCE(x.despachada,0) THEN ca.cantidad-COALESCE(x.despachada,0) ELSE 0 END pendiente_despacho,
       x.primera_salida,x.ultima_devolucion
FROM dbo.v_CondicionVigenteAlquiler ca
JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
OUTER APPLY
(
    SELECT SUM(CONVERT(BIGINT,e.cantidad_despachada)) despachada,SUM(CONVERT(BIGINT,e.cantidad_devuelta)) devuelta,
           SUM(CONVERT(BIGINT,e.pendiente)) pendiente,MIN(d.fecha_salida) primera_salida,MAX(e.ultima_devolucion) ultima_devolucion
    FROM dbo.ReservaEquipo re JOIN dbo.v_EntregaSaldo e ON e.id_reserva=re.id_reserva
    JOIN dbo.Despacho d ON d.id_despacho=e.id_despacho
    WHERE re.id_detalle_alquiler=ca.id_detalle_alquiler
) x
WHERE r.naturaleza='EQUIPO';
GO

/* 06 - Intervalos reales de uso; Power BI puede agruparlos por mes, recurso o categoria. */
CREATE OR ALTER VIEW bi.vw_06_UtilizacionEquipos AS
SELECT e.id_detalle_despacho,a.id_alquiler,a.numero_alquiler,ca.id_recurso,r.codigo,r.nombre AS recurso,
       cat.nombre AS categoria,d.fecha_salida,e.ultima_devolucion,
       COALESCE(e.ultima_devolucion,SYSDATETIME()) fecha_fin_uso,
       e.cantidad_despachada,e.cantidad_devuelta,e.pendiente,
       CONVERT(DECIMAL(18,4),e.cantidad_despachada*DATEDIFF_BIG(SECOND,d.fecha_salida,COALESCE(e.ultima_devolucion,SYSDATETIME()))/86400.0) unidades_dia_alquiladas,
       DATEFROMPARTS(YEAR(d.fecha_salida),MONTH(d.fecha_salida),1) mes_salida,
       cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra
FROM dbo.v_EntregaSaldo e
JOIN dbo.Despacho d ON d.id_despacho=e.id_despacho
JOIN dbo.ReservaEquipo re ON re.id_reserva=e.id_reserva
JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
JOIN dbo.Cotizacion co ON co.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=co.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
JOIN dbo.Categoria cat ON cat.id_categoria=r.id_categoria
WHERE r.naturaleza='EQUIPO';
GO

/* 07 - Liquidacion consolidada por alquiler. */
CREATE OR ALTER VIEW bi.vw_07_Liquidacion AS
SELECT a.id_alquiler,a.numero_alquiler,a.fecha_confirmacion,a.estado_operativo,
       cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,o.ciudad,
       l.equipos,l.personal,l.transporte,l.otros_conceptos,l.conceptos_cotizacion,
       l.retrasos,l.danos,l.faltantes,l.otros_cargos,l.cargos_adicionales,l.ajustes,l.total_vigente,
       l.anticipos,l.pagos_recibidos,l.reembolsos_efectivos,l.reembolsos_pendientes
FROM dbo.v_Liquidacion l
JOIN dbo.Alquiler a ON a.id_alquiler=l.id_alquiler
JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra;
GO

/* 08 - Pagos y saldos calculados sin duplicar movimientos. */
CREATE OR ALTER VIEW bi.vw_08_PagosSaldos AS
SELECT l.*,
       l.pagos_recibidos-l.reembolsos_efectivos AS pagos_netos,
       CASE WHEN l.total_vigente>l.pagos_recibidos-l.reembolsos_efectivos
            THEN l.total_vigente-(l.pagos_recibidos-l.reembolsos_efectivos) ELSE 0 END saldo_pendiente,
       CASE WHEN l.pagos_recibidos-l.reembolsos_efectivos>l.total_vigente
            THEN l.pagos_recibidos-l.reembolsos_efectivos-l.total_vigente ELSE 0 END excedente
FROM bi.vw_07_Liquidacion l;
GO

/* 09 - Valores y recaudo por cliente, obra, alquiler y periodo. */
CREATE OR ALTER VIEW bi.vw_09_ValoresRecaudos AS
SELECT l.id_alquiler,l.numero_alquiler,l.fecha_confirmacion,
       DATEFROMPARTS(YEAR(l.fecha_confirmacion),MONTH(l.fecha_confirmacion),1) mes_confirmacion,
       l.id_cliente,l.razon_social,l.id_obra,l.obra,l.ciudad,
       l.equipos,l.personal,l.transporte,l.otros_conceptos,l.cargos_adicionales,l.ajustes,l.total_vigente,
       l.pagos_recibidos AS recaudo_bruto,l.reembolsos_efectivos,
       l.pagos_recibidos-l.reembolsos_efectivos AS recaudo_neto
FROM bi.vw_07_Liquidacion l;
GO

/* 10 - Incidencias, costos y cargos autorizados. */
CREATE OR ALTER VIEW bi.vw_10_Incidencias AS
SELECT i.id_incidencia,a.id_alquiler,a.numero_alquiler,cl.id_cliente,cl.razon_social,o.id_obra,o.nombre AS obra,
       ca.id_recurso,r.codigo,r.nombre AS recurso,i.tipo,i.cantidad_afectada,i.fecha_registro,
       i.descripcion,i.estado,i.resolucion,i.fecha_resolucion,i.costo_estimado,
       i.responsabilidad_acordada,i.fecha_evaluacion,COALESCE(x.cargo_autorizado,0) cargo_autorizado
FROM dbo.IncidenciaAlquiler i
JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=i.id_detalle_alquiler
JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada
JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
OUTER APPLY
(
    SELECT SUM(ca2.importe) cargo_autorizado
    FROM dbo.CargoIncidencia ci JOIN dbo.CargoAlquiler ca2 ON ca2.id_cargo=ci.id_cargo
    WHERE ci.id_incidencia=i.id_incidencia AND ca2.estado='VIGENTE'
) x;
GO

/* 11 - Inspecciones y material bloqueado despues del retorno. */
CREATE OR ALTER VIEW bi.vw_11_Inspecciones AS
SELECT di.id_detalle_inspeccion,ins.id_inspeccion,ins.fecha_inspeccion,
       e.id_empleado,e.nombre AS inspector,a.id_alquiler,a.numero_alquiler,
       ca.id_recurso,r.codigo,r.nombre AS recurso,dd.id_bodega_recepcion,b.nombre AS bodega,
       dv.fecha_recepcion,dd.cantidad_recibida,di.cantidad_revisada,cm.nombre AS condicion_resultante,
       cm.permite_despacho AS habilitado,di.observaciones
FROM dbo.DetalleInspeccion di
JOIN dbo.Inspeccion ins ON ins.id_inspeccion=di.id_inspeccion
JOIN dbo.Empleado e ON e.id_empleado=ins.id_empleado_inspector
JOIN dbo.DetalleDevolucion dd ON dd.id_detalle_devolucion=di.id_detalle_devolucion
JOIN dbo.Devolucion dv ON dv.id_devolucion=dd.id_devolucion
JOIN dbo.Alquiler a ON a.id_alquiler=dv.id_alquiler
JOIN dbo.DetalleDespacho des ON des.id_detalle_despacho=dd.id_detalle_despacho
JOIN dbo.ReservaEquipo re ON re.id_reserva=des.id_reserva
JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
JOIN dbo.Bodega b ON b.id_bodega=dd.id_bodega_recepcion
JOIN dbo.CondicionMaterial cm ON cm.id_condicion=di.id_condicion_resultante;
GO

/* 12 - Todas las evaluaciones; es_ultima permite reproducir el reporte sin duplicar versiones. */
CREATE OR ALTER VIEW bi.vw_12_DemandaNoAtendida AS
WITH evaluaciones AS
(
    SELECT e.*,ROW_NUMBER() OVER(PARTITION BY e.id_solicitud ORDER BY e.fecha_evaluacion DESC,e.id_evaluacion DESC) rn
    FROM dbo.EvaluacionDisponibilidad e
)
SELECT e.id_evaluacion,e.fecha_evaluacion,CONVERT(BIT,CASE WHEN e.rn=1 THEN 1 ELSE 0 END) es_ultima_evaluacion,
       s.id_solicitud,s.numero_solicitud,s.estado AS estado_solicitud,cl.id_cliente,cl.razon_social,
       o.id_obra,o.nombre AS obra,d.id_detalle_evaluacion,ds.id_recurso,r.codigo,r.nombre AS recurso,r.naturaleza,
       d.cantidad_solicitada_evaluada,d.cantidad_disponible,
       CASE WHEN d.cantidad_solicitada_evaluada>d.cantidad_disponible
            THEN d.cantidad_solicitada_evaluada-d.cantidad_disponible ELSE 0 END faltante,
       d.fecha_inicio_evaluada,d.fecha_fin_evaluada,d.depende_de_devoluciones,
       d.motivo_no_atencion,d.alternativa_propuesta,d.decision_cliente,d.fecha_decision_cliente
FROM evaluaciones e
JOIN dbo.Solicitud s ON s.id_solicitud=e.id_solicitud
JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente
JOIN dbo.Obra o ON o.id_obra=s.id_obra
JOIN dbo.DetalleEvaluacionDisponibilidad d ON d.id_evaluacion=e.id_evaluacion
JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=d.id_detalle_solicitud
JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso;
GO

IF DATABASE_PRINCIPAL_ID(N'dafel_powerbi') IS NULL CREATE ROLE dafel_powerbi AUTHORIZATION dbo;
GRANT SELECT ON SCHEMA::bi TO dafel_powerbi;
GO

IF DATABASE_PRINCIPAL_ID(N'lector_powerbi_test') IS NULL CREATE USER lector_powerbi_test WITHOUT LOGIN;
IF IS_ROLEMEMBER(N'dafel_powerbi',N'lector_powerbi_test')<>1 ALTER ROLE dafel_powerbi ADD MEMBER lector_powerbi_test;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'Capa de lectura para los informes academicos de Power BI.',@level0type=N'SCHEMA',@level0name=N'bi';
GO
