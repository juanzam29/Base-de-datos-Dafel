USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF EXISTS(SELECT 1 FROM dbo.Despacho WHERE numero_despacho='DESP-DEMO-001')
BEGIN
    PRINT N'Flujo operativo de demostracion ya ejecutado.';
    RETURN;
END;
GO

DECLARE
    @Alquiler INT,
    @DetalleEquipo INT,
    @DetallePersonal INT,
    @Bodega INT,
    @Usuario INT,
    @EmpleadoAdmin INT,
    @EmpleadoOperario INT,
    @Reserva INT,
    @Despacho INT,
    @DetalleDespacho INT,
    @Devolucion INT,
    @DetalleDevolucion INT,
    @Inspeccion INT,
    @CondicionDanado INT,
    @Total DECIMAL(18,2),
    @Pagos DECIMAL(18,2),
    @Saldo DECIMAL(18,2);

SELECT @Alquiler=id_alquiler FROM dbo.Alquiler WHERE numero_alquiler='ALQ-DEMO-001';
SELECT @DetalleEquipo=da.id_detalle_alquiler
FROM dbo.DetalleAlquiler da
JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso
WHERE da.id_alquiler=@Alquiler AND r.codigo='DAFEL-DEMO-AND';
SELECT @DetallePersonal=da.id_detalle_alquiler
FROM dbo.DetalleAlquiler da
JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso
WHERE da.id_alquiler=@Alquiler AND r.codigo='DAFEL-DEMO-OP';
SELECT @Bodega=id_bodega FROM dbo.Bodega WHERE nombre=N'Bodega principal Dafel';
SELECT @Usuario=id_usuario,@EmpleadoAdmin=id_empleado FROM dbo.Usuario WHERE nombre_usuario=N'daniel.demo';
SELECT @EmpleadoOperario=id_empleado FROM dbo.Empleado WHERE numero_documento='1000000002';
SELECT @CondicionDanado=id_condicion FROM dbo.CondicionMaterial WHERE nombre=N'DANADO';

IF @Alquiler IS NULL OR @DetalleEquipo IS NULL OR @DetallePersonal IS NULL OR
   @Bodega IS NULL OR @Usuario IS NULL OR @EmpleadoOperario IS NULL OR @CondicionDanado IS NULL
    THROW 55300,'No se encontraron todos los datos base de demostracion.',1;

EXEC sys.sp_set_session_context @key=N'id_usuario',@value=@Usuario;

EXEC operacion.usp_CrearReservaEquipo
    @IdDetalleAlquiler=@DetalleEquipo,
    @IdBodega=@Bodega,
    @Cantidad=3,
    @FechaInicio='2026-11-17T08:00:00',
    @FechaFin='2026-11-20T08:00:00';

SELECT TOP(1) @Reserva=id_reserva
FROM dbo.ReservaEquipo
WHERE id_detalle_alquiler=@DetalleEquipo AND id_bodega=@Bodega
ORDER BY id_reserva DESC;

EXEC operacion.usp_AsignarPersonalSeguro
    @IdDetalleAlquiler=@DetallePersonal,
    @IdEmpleado=@EmpleadoOperario,
    @IdUsuarioRegistro=@Usuario,
    @FechaInicio='2026-11-17T08:00:00',
    @FechaFin='2026-11-18T08:00:00';

BEGIN TRY
    EXEC operacion.usp_AsignarPersonalSeguro
        @IdDetalleAlquiler=@DetallePersonal,
        @IdEmpleado=@EmpleadoOperario,
        @IdUsuarioRegistro=@Usuario,
        @FechaInicio='2026-11-17T12:00:00',
        @FechaFin='2026-11-17T18:00:00';
    THROW 55301,'La prueba de cruce de personal no fue rechazada.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (55214,55104) THROW;
    PRINT N'OK: cruce de personal rechazado.';
END CATCH;

INSERT dbo.Despacho
    (id_alquiler,id_usuario_autorizador,id_empleado_entrega,numero_despacho,fecha_salida,estado)
VALUES(@Alquiler,@Usuario,@EmpleadoAdmin,'DESP-DEMO-001','2026-11-17T08:00:00','PREPARADO');
SET @Despacho=CONVERT(INT,SCOPE_IDENTITY());

EXEC operacion.usp_AutorizarDespacho @IdDespacho=@Despacho;

EXEC operacion.usp_RegistrarDetalleDespacho
    @IdDespacho=@Despacho,
    @IdReserva=@Reserva,
    @Cantidad=2,
    @Observaciones=N'Despacho parcial ficticio.';

SELECT TOP(1) @DetalleDespacho=id_detalle_despacho
FROM dbo.DetalleDespacho WHERE id_despacho=@Despacho ORDER BY id_detalle_despacho DESC;

INSERT dbo.Devolucion
    (id_alquiler,id_empleado_receptor,id_usuario_registro,numero_devolucion,fecha_recepcion)
VALUES(@Alquiler,@EmpleadoAdmin,@Usuario,'DEV-DEMO-001','2026-11-19T10:00:00');
SET @Devolucion=CONVERT(INT,SCOPE_IDENTITY());

EXEC operacion.usp_RegistrarDetalleDevolucion
    @IdDevolucion=@Devolucion,
    @IdDetalleDespacho=@DetalleDespacho,
    @IdBodegaRecepcion=@Bodega,
    @Cantidad=1,
    @Observaciones=N'Retorno parcial ficticio.';

SELECT TOP(1) @DetalleDevolucion=id_detalle_devolucion
FROM dbo.DetalleDevolucion WHERE id_devolucion=@Devolucion ORDER BY id_detalle_devolucion DESC;

INSERT dbo.Inspeccion
    (id_devolucion,id_empleado_inspector,id_usuario_registro,fecha_inspeccion,observaciones)
VALUES(@Devolucion,@EmpleadoAdmin,@Usuario,'2026-11-19T11:00:00',N'Inspeccion ficticia.');
SET @Inspeccion=CONVERT(INT,SCOPE_IDENTITY());

EXEC operacion.usp_RegistrarDetalleInspeccion
    @IdInspeccion=@Inspeccion,
    @IdDetalleDevolucion=@DetalleDevolucion,
    @IdCondicionResultado=@CondicionDanado,
    @Cantidad=1,
    @Observaciones=N'Unidad danada para la prueba.';

BEGIN TRY
    EXEC operacion.usp_RegistrarDetalleDevolucion
        @IdDevolucion=@Devolucion,
        @IdDetalleDespacho=@DetalleDespacho,
        @IdBodegaRecepcion=@Bodega,
        @Cantidad=2,
        @Observaciones=N'Debe fallar por exceso.';
    THROW 55302,'La devolucion excesiva no fue rechazada.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55102 THROW;
    PRINT N'OK: devolucion acumulada excesiva rechazada.';
END CATCH;

BEGIN TRY
    EXEC operacion.usp_RegistrarDetalleInspeccion
        @IdInspeccion=@Inspeccion,
        @IdDetalleDevolucion=@DetalleDevolucion,
        @IdCondicionResultado=@CondicionDanado,
        @Cantidad=1,
        @Observaciones=N'Debe fallar por exceso.';
    THROW 55303,'La inspeccion excesiva no fue rechazada.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55103 THROW;
    PRINT N'OK: inspeccion acumulada excesiva rechazada.';
END CATCH;

BEGIN TRY
    EXEC operacion.usp_AutorizarReembolso
        @IdAlquiler=@Alquiler,
        @IdUsuarioAutorizador=@Usuario,
        @IdUsuarioRegistro=@Usuario,
        @Importe=500000,
        @Motivo=N'Debe fallar por exceso.';
    THROW 55304,'El reembolso excesivo no fue rechazado.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55261 THROW;
    PRINT N'OK: reembolso excesivo rechazado.';
END CATCH;

SELECT @Total=total_vigente,@Pagos=pagos_recibidos,
       @Saldo=CASE WHEN total_vigente>pagos_recibidos-reembolsos_efectivos
                   THEN total_vigente-(pagos_recibidos-reembolsos_efectivos) ELSE 0 END
FROM dbo.v_Liquidacion WHERE id_alquiler=@Alquiler;

IF @Total<>490000 THROW 55310,'Total esperado distinto de 490000.',1;
IF @Pagos<>440000 THROW 55311,'Pago esperado distinto de 440000.',1;
IF @Saldo<>50000 THROW 55312,'Saldo esperado distinto de 50000.',1;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.v_EntregaSaldo
    WHERE id_detalle_despacho=@DetalleDespacho
      AND cantidad_despachada=2 AND cantidad_devuelta=1 AND pendiente=1
)
    THROW 55313,'El saldo fisico de la entrega no coincide con 2/1/1.',1;

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.v_SaldoFisico s
    JOIN dbo.Recurso r ON r.id_recurso=s.id_recurso
    JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion
    WHERE r.codigo='DAFEL-DEMO-AND' AND c.nombre=N'DANADO' AND s.cantidad=1
)
    THROW 55314,'La unidad danada no quedo registrada en el saldo fisico.',1;

SELECT @Total total_vigente,@Pagos pagos_recibidos,@Saldo saldo_pendiente;
PRINT N'PRUEBAS OPERATIVAS COMPLETADAS';
GO
