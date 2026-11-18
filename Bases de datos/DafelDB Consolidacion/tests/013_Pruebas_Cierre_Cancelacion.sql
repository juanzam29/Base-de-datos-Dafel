USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @AlquilerPrincipal INT,@AlquilerFuturo INT,@Usuario INT,@Empleado INT,@DespachoPrueba INT;
SELECT @AlquilerPrincipal=id_alquiler FROM dbo.Alquiler WHERE numero_alquiler='ALQ-DEMO-001';
SELECT @AlquilerFuturo=id_alquiler FROM dbo.Alquiler WHERE numero_alquiler='ALQ-DEMO-FUTURO';
SELECT @Usuario=id_usuario,@Empleado=id_empleado FROM dbo.Usuario WHERE nombre_usuario=N'daniel.demo';

BEGIN TRY
    EXEC operacion.usp_CerrarAlquiler @IdAlquiler=@AlquilerPrincipal,@TipoCierre='OPERATIVO';
    THROW 55600,'El cierre operativo con devolucion pendiente no fue rechazado.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55272 THROW;
    PRINT N'OK: cierre operativo incompleto rechazado.';
END CATCH;

BEGIN TRY
    EXEC operacion.usp_CerrarAlquiler @IdAlquiler=@AlquilerPrincipal,@TipoCierre='FINANCIERO';
    THROW 55601,'El cierre financiero con saldo no fue rechazado.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55274 THROW;
    PRINT N'OK: cierre financiero con saldo rechazado.';
END CATCH;

INSERT dbo.Despacho
    (id_alquiler,id_usuario_autorizador,id_empleado_entrega,numero_despacho,fecha_salida,estado)
VALUES(@AlquilerFuturo,@Usuario,@Empleado,'DESP-SIN-PAGO-TEST','2026-11-22T07:00:00','PREPARADO');
SET @DespachoPrueba=CONVERT(INT,SCOPE_IDENTITY());

BEGIN TRY
    EXEC operacion.usp_AutorizarDespacho @IdDespacho=@DespachoPrueba;
    THROW 55602,'El despacho sin anticipo no fue rechazado.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>55221 THROW;
    PRINT N'OK: despacho sin anticipo rechazado.';
END CATCH;

DELETE dbo.Despacho WHERE id_despacho=@DespachoPrueba;

BEGIN TRANSACTION;
INSERT dbo.Pago
    (id_alquiler,id_usuario_registro,fecha_pago,importe,medio_pago,
     referencia_transaccion,estado,tipo_pago)
VALUES(@AlquilerFuturo,@Usuario,'2026-11-16T13:10:00',5000,'TRANSFERENCIA',
       N'DEMO-CANCELACION','VIGENTE','ANTICIPO');

EXEC operacion.usp_CancelarAlquilerAntesDespacho
    @IdAlquiler=@AlquilerFuturo,
    @IdUsuarioAutorizador=@Usuario,
    @IdUsuarioRegistro=@Usuario,
    @Motivo=N'Cancelacion ficticia antes del despacho.';

IF NOT EXISTS
(
    SELECT 1 FROM dbo.Alquiler
    WHERE id_alquiler=@AlquilerFuturo AND estado_operativo='CANCELADO'
)
    THROW 55603,'El alquiler no quedo cancelado.',1;

IF NOT EXISTS
(
    SELECT 1 FROM dbo.Reembolso
    WHERE id_alquiler=@AlquilerFuturo AND importe=5000 AND estado='AUTORIZADO'
)
    THROW 55604,'No se autorizo el reembolso total esperado.',1;

IF EXISTS
(
    SELECT 1 FROM dbo.v_ReservaVigente v
    JOIN dbo.ReservaEquipo r ON r.id_reserva=v.id_reserva
    JOIN dbo.DetalleAlquiler da ON da.id_detalle_alquiler=r.id_detalle_alquiler
    WHERE da.id_alquiler=@AlquilerFuturo AND v.estado='ACTIVA'
)
    THROW 55605,'Quedaron reservas activas tras la cancelacion.',1;

ROLLBACK TRANSACTION;
PRINT N'OK: cancelacion libera reservas y autoriza reembolso; prueba revertida.';
PRINT N'PRUEBAS DE CIERRE Y CANCELACION COMPLETADAS';
GO
