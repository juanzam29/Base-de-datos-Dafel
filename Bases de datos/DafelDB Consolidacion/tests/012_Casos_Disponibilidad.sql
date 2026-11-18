USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF EXISTS(SELECT 1 FROM dbo.Solicitud WHERE numero_solicitud='SOL-DEMO-FUTURA')
BEGIN
    PRINT N'Casos de disponibilidad ya cargados.';
    RETURN;
END;
GO

DECLARE
    @Cliente INT,
    @Obra INT,
    @Usuario INT,
    @Recurso INT,
    @Unidad INT,
    @Bodega INT,
    @SolicitudParcial INT,
    @DetalleParcial INT,
    @Evaluacion1 INT,
    @Evaluacion2 INT,
    @SolicitudFutura INT,
    @DetalleFuturo1 INT,
    @DetalleFuturo2 INT,
    @Cotizacion INT,
    @DetalleCotizacion1 INT,
    @DetalleCotizacion2 INT,
    @Alquiler INT,
    @DetalleAlquiler1 INT,
    @DetalleAlquiler2 INT,
    @Pico BIGINT;

SELECT @Cliente=id_cliente FROM dbo.Cliente WHERE nit='900000001-1';
SELECT @Obra=id_obra FROM dbo.Obra WHERE nombre=N'Obra demostracion Dafel';
SELECT @Usuario=id_usuario FROM dbo.Usuario WHERE nombre_usuario=N'daniel.demo';
SELECT @Recurso=id_recurso FROM dbo.Recurso WHERE codigo='DAFEL-DEMO-AND';
SELECT @Unidad=id_unidad_cobro FROM dbo.UnidadCobro WHERE nombre=N'BLOQUE_24_HORAS';
SELECT @Bodega=id_bodega FROM dbo.Bodega WHERE nombre=N'Bodega principal Dafel';

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT dbo.Solicitud
        (id_cliente,id_obra,numero_solicitud,fecha_registro,canal,estado,observaciones)
    VALUES(@Cliente,@Obra,'SOL-DEMO-PARCIAL','2026-11-16T11:00:00','WHATSAPP',
           'EN_REVISION',N'Caso ficticio de disponibilidad parcial.');
    SET @SolicitudParcial=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleSolicitud
        (id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
    VALUES(@SolicitudParcial,@Recurso,1,5,'2026-11-22T08:00:00','2026-11-25T08:00:00');
    SET @DetalleParcial=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.EvaluacionDisponibilidad(id_solicitud,id_usuario_evaluador,fecha_evaluacion)
    VALUES(@SolicitudParcial,@Usuario,'2026-11-16T11:10:00');
    SET @Evaluacion1=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleEvaluacionDisponibilidad
        (id_evaluacion,id_detalle_solicitud,cantidad_solicitada_evaluada,cantidad_disponible,
         fecha_inicio_evaluada,fecha_fin_evaluada,depende_de_devoluciones,
         motivo_no_atencion,alternativa_propuesta,decision_cliente,fecha_decision_cliente)
    VALUES(@Evaluacion1,@DetalleParcial,5,1,'2026-11-22T08:00:00','2026-11-25T08:00:00',1,
           N'Disponibilidad inicial insuficiente.',N'Revisar fechas alternativas.','PENDIENTE',NULL);

    INSERT dbo.EvaluacionDisponibilidad(id_solicitud,id_usuario_evaluador,fecha_evaluacion)
    VALUES(@SolicitudParcial,@Usuario,'2026-11-16T12:00:00');
    SET @Evaluacion2=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleEvaluacionDisponibilidad
        (id_evaluacion,id_detalle_solicitud,cantidad_solicitada_evaluada,cantidad_disponible,
         fecha_inicio_evaluada,fecha_fin_evaluada,depende_de_devoluciones,
         motivo_no_atencion,alternativa_propuesta,decision_cliente,fecha_decision_cliente)
    VALUES(@Evaluacion2,@DetalleParcial,5,2,'2026-11-22T08:00:00','2026-11-25T08:00:00',1,
           N'Faltan tres unidades.',N'Entregar dos unidades o cambiar fechas.','PENDIENTE',NULL);

    INSERT dbo.Solicitud
        (id_cliente,id_obra,numero_solicitud,fecha_registro,canal,estado,observaciones)
    VALUES(@Cliente,@Obra,'SOL-DEMO-FUTURA','2026-11-16T12:30:00','WEB','CONVERTIDA',
           N'Dos periodos no simultaneos para validar el pico.');
    SET @SolicitudFutura=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleSolicitud
        (id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
    VALUES(@SolicitudFutura,@Recurso,1,3,'2026-11-22T08:00:00','2026-11-23T08:00:00');
    SET @DetalleFuturo1=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleSolicitud
        (id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
    VALUES(@SolicitudFutura,@Recurso,2,4,'2026-11-24T08:00:00','2026-11-25T08:00:00');
    SET @DetalleFuturo2=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Cotizacion
        (id_solicitud,id_usuario_autorizador,numero_version,fecha_emision,fecha_vencimiento,
         fecha_autorizacion,estado,fecha_respuesta)
    VALUES(@SolicitudFutura,@Usuario,1,'2026-11-16T12:40:00','2026-11-17T12:40:00',
           '2026-11-16T12:45:00','BORRADOR','2026-11-16T12:50:00');
    SET @Cotizacion=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleCotizacion
        (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
         fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
    VALUES(@Cotizacion,@DetalleFuturo1,@Unidad,1,3,
           '2026-11-22T08:00:00','2026-11-23T08:00:00',70000,1);
    SET @DetalleCotizacion1=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleCotizacion
        (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
         fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
    VALUES(@Cotizacion,@DetalleFuturo2,@Unidad,2,4,
           '2026-11-24T08:00:00','2026-11-25T08:00:00',70000,1);
    SET @DetalleCotizacion2=CONVERT(INT,SCOPE_IDENTITY());

    UPDATE dbo.Cotizacion SET estado='ACEPTADA' WHERE id_cotizacion=@Cotizacion;

    INSERT dbo.Alquiler
        (id_cotizacion_aceptada,id_usuario_aprobador,numero_alquiler,fecha_confirmacion,
         estado_operativo,fecha_limite_pago,porcentaje_anticipo_requerido)
    VALUES(@Cotizacion,@Usuario,'ALQ-DEMO-FUTURO','2026-11-16T13:00:00',
           'CONFIRMADO','2026-11-22T07:00:00',100);
    SET @Alquiler=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
    VALUES(@Alquiler,@DetalleCotizacion1);
    SET @DetalleAlquiler1=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
    VALUES(@Alquiler,@DetalleCotizacion2);
    SET @DetalleAlquiler2=CONVERT(INT,SCOPE_IDENTITY());

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

EXEC operacion.usp_CrearReservaEquipo
    @IdDetalleAlquiler=@DetalleAlquiler1,@IdBodega=@Bodega,@Cantidad=3,
    @FechaInicio='2026-11-22T08:00:00',@FechaFin='2026-11-23T08:00:00';
EXEC operacion.usp_CrearReservaEquipo
    @IdDetalleAlquiler=@DetalleAlquiler2,@IdBodega=@Bodega,@Cantidad=4,
    @FechaInicio='2026-11-24T08:00:00',@FechaFin='2026-11-25T08:00:00';

;WITH compromisos AS
(
    SELECT v.fecha_inicio,v.fecha_fin,v.cantidad_comprometida
    FROM dbo.v_ReservaVigente v
    JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=v.id_detalle_alquiler
    WHERE ca.id_recurso=@Recurso AND v.id_bodega=@Bodega AND v.estado='ACTIVA'
      AND v.fecha_inicio<'2026-11-26T00:00:00' AND v.fecha_fin>'2026-11-22T00:00:00'
),
puntos AS
(
    SELECT CONVERT(DATETIME2(0),'2026-11-22T00:00:00') fecha
    UNION SELECT fecha_inicio FROM compromisos
),
cargas AS
(
    SELECT p.fecha,SUM(c.cantidad_comprometida) cantidad
    FROM puntos p
    JOIN compromisos c ON c.fecha_inicio<=p.fecha AND c.fecha_fin>p.fecha
    GROUP BY p.fecha
)
SELECT @Pico=MAX(cantidad) FROM cargas;

IF @Pico<>4 THROW 55500,'El pico simultaneo esperado era 4, no la suma 7.',1;

IF (SELECT COUNT(*) FROM dbo.EvaluacionDisponibilidad WHERE id_solicitud=@SolicitudParcial)<>2
    THROW 55501,'No se conservaron las dos evaluaciones historicas.',1;

IF NOT EXISTS
(
    SELECT 1
    FROM
    (
        SELECT id_evaluacion,
               ROW_NUMBER() OVER(ORDER BY fecha_evaluacion DESC,id_evaluacion DESC) rn
        FROM dbo.EvaluacionDisponibilidad
        WHERE id_solicitud=@SolicitudParcial
    ) u
    JOIN dbo.DetalleEvaluacionDisponibilidad d ON d.id_evaluacion=u.id_evaluacion
    WHERE u.rn=1 AND d.cantidad_disponible=2
)
    THROW 55502,'La ultima evaluacion no conserva la disponibilidad esperada.',1;

SELECT @Pico AS pico_simultaneo_esperado;
PRINT N'CASOS DE DISPONIBILIDAD COMPLETADOS';
GO
