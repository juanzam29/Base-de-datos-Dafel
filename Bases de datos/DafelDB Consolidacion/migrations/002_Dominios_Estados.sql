/* Technical project domains, not confirmed corporate policies. WITH CHECK stops on incompatible existing values. No data is silently converted. These domains do not enforce legal transition order. */
USE [DafelDB_Validacion];
GO
SET XACT_ABORT ON;
BEGIN TRY
 BEGIN TRANSACTION;
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.Cotizacion') AND name=N'CK_Cotizacion_dominio_estado') ALTER TABLE dbo.Cotizacion WITH CHECK ADD CONSTRAINT CK_Cotizacion_dominio_estado CHECK(estado IN('BORRADOR','AUTORIZADA','ENVIADA','ACEPTADA','RECHAZADA','VENCIDA','ANULADA'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.Alquiler') AND name=N'CK_Alquiler_dominio_estado') ALTER TABLE dbo.Alquiler WITH CHECK ADD CONSTRAINT CK_Alquiler_dominio_estado CHECK(estado_operativo IN('CONFIRMADO','EN_PREPARACION','EN_CURSO','PENDIENTE_DEVOLUCION','CERRADO','CANCELADO'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.SolicitudCambio') AND name=N'CK_SolicitudCambio_dominio_estado') ALTER TABLE dbo.SolicitudCambio WITH CHECK ADD CONSTRAINT CK_SolicitudCambio_dominio_estado CHECK(estado IN('PENDIENTE','EN_REVISION','APROBADA','RECHAZADA','CANCELADA'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.VersionReservaEquipo') AND name=N'CK_VersionReservaEquipo_dominio_estado') ALTER TABLE dbo.VersionReservaEquipo WITH CHECK ADD CONSTRAINT CK_VersionReservaEquipo_dominio_estado CHECK(estado IN('ACTIVA','LIBERADA','CANCELADA','CERRADA'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.Despacho') AND name=N'CK_Despacho_dominio_estado') ALTER TABLE dbo.Despacho WITH CHECK ADD CONSTRAINT CK_Despacho_dominio_estado CHECK(estado IN('PREPARADO','AUTORIZADO','EN_TRANSITO','ENTREGADO','CANCELADO'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.AsignacionPersonal') AND name=N'CK_AsignacionPersonal_dominio_estado') ALTER TABLE dbo.AsignacionPersonal WITH CHECK ADD CONSTRAINT CK_AsignacionPersonal_dominio_estado CHECK(estado IN('PROGRAMADA','CONFIRMADA','EN_CURSO','FINALIZADA','CANCELADA','REEMPLAZADA'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.RegistroServicioPersonal') AND name=N'CK_RegistroServicioPersonal_dominio_estado') ALTER TABLE dbo.RegistroServicioPersonal WITH CHECK ADD CONSTRAINT CK_RegistroServicioPersonal_dominio_estado CHECK(estado IN('PENDIENTE','EN_CURSO','FINALIZADO','AUSENCIA','CANCELADO'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.IncidenciaAlquiler') AND name=N'CK_IncidenciaAlquiler_dominio_estado') ALTER TABLE dbo.IncidenciaAlquiler WITH CHECK ADD CONSTRAINT CK_IncidenciaAlquiler_dominio_estado CHECK(estado IN('ABIERTA','EN_EVALUACION','AUTORIZADA','RESUELTA','ANULADA'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.Reembolso') AND name=N'CK_Reembolso_dominio_estado') ALTER TABLE dbo.Reembolso WITH CHECK ADD CONSTRAINT CK_Reembolso_dominio_estado CHECK(estado IN('AUTORIZADO','EFECTUADO','ANULADO'));
 IF NOT EXISTS(SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'dbo.ActividadSeguimiento') AND name=N'CK_ActividadSeguimiento_dominio_estado') ALTER TABLE dbo.ActividadSeguimiento WITH CHECK ADD CONSTRAINT CK_ActividadSeguimiento_dominio_estado CHECK(estado IN('PROGRAMADA','REALIZADA','REPROGRAMADA','CANCELADA','SIN_RESPUESTA'));
 COMMIT;
END TRY BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK;
 THROW;
END CATCH;
GO
