USE [DafelDB_Validacion];
GO
IF SCHEMA_ID(N'operacion') IS NULL EXEC(N'CREATE SCHEMA operacion AUTHORIZATION dbo;');
IF SCHEMA_ID(N'reporte') IS NULL EXEC(N'CREATE SCHEMA reporte AUTHORIZATION dbo;');
GO
CREATE OR ALTER TRIGGER dbo.TR_ActividadCliente_Auditoria ON dbo.[ActividadCliente] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ActividadCliente',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ActividadSeguimiento_Auditoria ON dbo.[ActividadSeguimiento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ActividadSeguimiento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ActividadSolicitud_Auditoria ON dbo.[ActividadSolicitud] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ActividadSolicitud',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_AjusteEconomicoAlquiler_Auditoria ON dbo.[AjusteEconomicoAlquiler] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'AjusteEconomicoAlquiler',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_AjusteSolicitudCambio_Auditoria ON dbo.[AjusteSolicitudCambio] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'AjusteSolicitudCambio',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Alquiler_Auditoria ON dbo.[Alquiler] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Alquiler',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_AsignacionPersonal_Auditoria ON dbo.[AsignacionPersonal] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'AsignacionPersonal',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Bodega_Auditoria ON dbo.[Bodega] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Bodega',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_CambioVersionReserva_Auditoria ON dbo.[CambioVersionReserva] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'CambioVersionReserva',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_CargoAlquiler_Auditoria ON dbo.[CargoAlquiler] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'CargoAlquiler',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_CargoIncidencia_Auditoria ON dbo.[CargoIncidencia] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'CargoIncidencia',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Categoria_Auditoria ON dbo.[Categoria] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Categoria',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Cliente_Auditoria ON dbo.[Cliente] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Cliente',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ConceptoCotizacion_AceptadaInmutable ON dbo.ConceptoCotizacion AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Cotizacion c ON c.id_cotizacion=i.id_cotizacion WHERE c.estado='ACEPTADA')
 OR EXISTS(SELECT 1 FROM deleted d JOIN dbo.Cotizacion c ON c.id_cotizacion=d.id_cotizacion WHERE c.estado='ACEPTADA')
 THROW 53112,'Los conceptos de una cotizacion aceptada se conservan.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ConceptoCotizacion_Auditoria ON dbo.[ConceptoCotizacion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ConceptoCotizacion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_CondicionMaterial_Auditoria ON dbo.[CondicionMaterial] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'CondicionMaterial',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ConstanciaEntrega_Auditoria ON dbo.[ConstanciaEntrega] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ConstanciaEntrega',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
/* Accepted commercial terms are historical. Changes use SolicitudCambio and adjustments. */
CREATE OR ALTER TRIGGER dbo.TR_Cotizacion_AceptadaInmutable ON dbo.Cotizacion AFTER UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE estado='ACEPTADA')
 THROW 53110,'La cotizacion aceptada se conserva. Registre un cambio del alquiler.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Cotizacion_Auditoria ON dbo.[Cotizacion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Cotizacion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DespachoDetalleDocumento_Auditoria ON dbo.[DespachoDetalleDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DespachoDetalleDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Despacho_Auditoria ON dbo.[Despacho] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Despacho',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleAlquiler_Auditoria ON dbo.[DetalleAlquiler] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleAlquiler',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleAlquiler_Correspondencia ON dbo.DetalleAlquiler AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Alquiler a ON a.id_alquiler=i.id_alquiler JOIN dbo.DetalleCotizacion c ON c.id_detalle_cotizacion=i.id_detalle_cotizacion WHERE a.id_cotizacion_aceptada<>c.id_cotizacion)
 THROW 53102,'La linea alquilada no pertenece a la cotizacion aceptada.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleCotizacion_AceptadaInmutable ON dbo.DetalleCotizacion AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Cotizacion c ON c.id_cotizacion=i.id_cotizacion WHERE c.estado='ACEPTADA')
 OR EXISTS(SELECT 1 FROM deleted d JOIN dbo.Cotizacion c ON c.id_cotizacion=d.id_cotizacion WHERE c.estado='ACEPTADA')
 THROW 53111,'Las lineas de una cotizacion aceptada no se agregan, editan ni eliminan.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleCotizacion_Auditoria ON dbo.[DetalleCotizacion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleCotizacion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
/* Prevent cross-header references which a single-column FK alone cannot detect. */
CREATE OR ALTER TRIGGER dbo.TR_DetalleCotizacion_Correspondencia ON dbo.DetalleCotizacion AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Cotizacion c ON c.id_cotizacion=i.id_cotizacion JOIN dbo.DetalleSolicitud d ON d.id_detalle_solicitud=i.id_detalle_solicitud WHERE c.id_solicitud<>d.id_solicitud)
 THROW 53101,'La linea cotizada pertenece a otra solicitud.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleDespacho_Auditoria ON dbo.[DetalleDespacho] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleDespacho',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleDespacho_Correspondencia ON dbo.DetalleDespacho AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Despacho d ON d.id_despacho=i.id_despacho JOIN dbo.ReservaEquipo r ON r.id_reserva=i.id_reserva JOIN dbo.DetalleAlquiler a ON a.id_detalle_alquiler=r.id_detalle_alquiler WHERE d.id_alquiler<>a.id_alquiler)
 THROW 53103,'La reserva despachada pertenece a otro alquiler.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleDevolucion_Auditoria ON dbo.[DetalleDevolucion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleDevolucion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleDevolucion_Correspondencia ON dbo.DetalleDevolucion AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Devolucion v ON v.id_devolucion=i.id_devolucion JOIN dbo.DetalleDespacho dd ON dd.id_detalle_despacho=i.id_detalle_despacho JOIN dbo.Despacho d ON d.id_despacho=dd.id_despacho WHERE v.id_alquiler<>d.id_alquiler)
 THROW 53104,'La devolucion no corresponde al alquiler despachado.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleEvaluacionDisponibilidad_Auditoria ON dbo.[DetalleEvaluacionDisponibilidad] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleEvaluacionDisponibilidad',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleInspeccion_Auditoria ON dbo.[DetalleInspeccion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleInspeccion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleInspeccion_Correspondencia ON dbo.DetalleInspeccion AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Inspeccion x ON x.id_inspeccion=i.id_inspeccion JOIN dbo.DetalleDevolucion d ON d.id_detalle_devolucion=i.id_detalle_devolucion WHERE x.id_devolucion<>d.id_devolucion)
 THROW 53105,'La linea inspeccionada corresponde a otra devolucion.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleMovimientoInventario_Auditoria ON dbo.[DetalleMovimientoInventario] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleMovimientoInventario',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleSolicitudCambio_Auditoria ON dbo.[DetalleSolicitudCambio] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleSolicitudCambio',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DetalleSolicitud_Auditoria ON dbo.[DetalleSolicitud] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DetalleSolicitud',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_DevolucionDocumento_Auditoria ON dbo.DevolucionDocumento AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'DevolucionDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Devolucion_Auditoria ON dbo.[Devolucion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Devolucion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Documento_Auditoria ON dbo.[Documento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Documento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_EmpleadoServicio_Auditoria ON dbo.[EmpleadoServicio] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'EmpleadoServicio',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_EmpleadoServicio_Tipo ON dbo.EmpleadoServicio AFTER INSERT,UPDATE AS
 BEGIN SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.Recurso r ON r.id_recurso=i.id_recurso WHERE r.naturaleza<>'PERSONAL')
 THROW 51000, 'Solo se pueden vincular empleados a servicios de PERSONAL.',1;
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Empleado_Auditoria ON dbo.[Empleado] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Empleado',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_EntregaDocumento_Auditoria ON dbo.[EntregaDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'EntregaDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_EvaluacionDisponibilidad_Auditoria ON dbo.[EvaluacionDisponibilidad] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'EvaluacionDisponibilidad',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_IncidenciaAlquiler_Auditoria ON dbo.[IncidenciaAlquiler] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'IncidenciaAlquiler',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_IncidenciaDocumento_Auditoria ON dbo.[IncidenciaDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'IncidenciaDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_IncidenciaInspeccion_Auditoria ON dbo.[IncidenciaInspeccion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'IncidenciaInspeccion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_IndisponibilidadPersonal_Auditoria ON dbo.[IndisponibilidadPersonal] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'IndisponibilidadPersonal',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_InspeccionDetalleDocumento_Auditoria ON dbo.[InspeccionDetalleDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'InspeccionDetalleDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Inspeccion_Auditoria ON dbo.[Inspeccion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Inspeccion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_MovimientoDespacho_Auditoria ON dbo.[MovimientoDespacho] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'MovimientoDespacho',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_MovimientoDevolucion_Auditoria ON dbo.[MovimientoDevolucion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'MovimientoDevolucion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_MovimientoInspeccion_Auditoria ON dbo.[MovimientoInspeccion] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'MovimientoInspeccion',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_MovimientoInventario_Auditoria ON dbo.[MovimientoInventario] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'MovimientoInventario',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_MovimientoRevisionMaterial_Auditoria ON dbo.[MovimientoRevisionMaterial] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'MovimientoRevisionMaterial',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Obra_Auditoria ON dbo.[Obra] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Obra',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_PagoDocumento_Auditoria ON dbo.[PagoDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'PagoDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Pago_Auditoria ON dbo.[Pago] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Pago',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Recurso_Auditoria ON dbo.[Recurso] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Recurso',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Recurso_ConservarNaturaleza ON dbo.Recurso AFTER UPDATE AS
 BEGIN SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.id_recurso=i.id_recurso WHERE i.naturaleza<>d.naturaleza AND (EXISTS(SELECT 1 FROM dbo.DetalleSolicitud s WHERE s.id_recurso=i.id_recurso) OR EXISTS(SELECT 1 FROM dbo.EmpleadoServicio e WHERE e.id_recurso=i.id_recurso)))
 THROW 51001, 'Un recurso utilizado no puede cambiar de naturaleza.',1;
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ReembolsoDocumento_Auditoria ON dbo.[ReembolsoDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ReembolsoDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Reembolso_Auditoria ON dbo.[Reembolso] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Reembolso',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_RegistroServicioPersonal_Auditoria ON dbo.[RegistroServicioPersonal] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'RegistroServicioPersonal',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_ReservaEquipo_Auditoria ON dbo.[ReservaEquipo] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'ReservaEquipo',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_RevisionDocumento_Auditoria ON dbo.[RevisionDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'RevisionDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_RevisionMaterialDocumento_Auditoria ON dbo.[RevisionMaterialDocumento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'RevisionMaterialDocumento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_RevisionMaterial_Auditoria ON dbo.[RevisionMaterial] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'RevisionMaterial',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_RevisionSolicitud_Auditoria ON dbo.[RevisionSolicitud] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'RevisionSolicitud',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Rol_Auditoria ON dbo.[Rol] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Rol',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_SolicitudCambio_Auditoria ON dbo.[SolicitudCambio] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'SolicitudCambio',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_Solicitud_Auditoria ON dbo.[Solicitud] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Solicitud',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_TarifaRecurso_Auditoria ON dbo.[TarifaRecurso] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'TarifaRecurso',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_TipoMovimiento_Auditoria ON dbo.[TipoMovimiento] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'TipoMovimiento',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_UnidadCobro_Auditoria ON dbo.[UnidadCobro] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'UnidadCobro',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER TRIGGER dbo.TR_UsuarioRol_Auditoria ON dbo.[UsuarioRol] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'UsuarioRol',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
-- El trigger de Usuario excluye expresamente el hash de los datos auditados.
CREATE OR ALTER TRIGGER dbo.TR_Usuario_Auditoria ON dbo.Usuario AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'Usuario',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT id_usuario,id_empleado,nombre_usuario,activo FROM deleted FOR JSON PATH),
 (SELECT id_usuario,id_empleado,nombre_usuario,activo FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
END;
GO
CREATE OR ALTER TRIGGER dbo.TR_VersionReservaEquipo_Auditoria ON dbo.[VersionReservaEquipo] AFTER INSERT, UPDATE, DELETE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.Auditoria(tabla,operacion,usuario_aplicacion,datos_anteriores,datos_nuevos)
 SELECT N'VersionReservaEquipo',CASE WHEN EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted) THEN 'UPDATE' WHEN EXISTS(SELECT 1 FROM inserted) THEN 'INSERT' ELSE 'DELETE' END,
 CONVERT(NVARCHAR(100),SESSION_CONTEXT(N'id_usuario')),
 (SELECT * FROM deleted FOR JSON PATH),(SELECT * FROM inserted FOR JSON PATH)
 WHERE EXISTS(SELECT 1 FROM inserted) OR EXISTS(SELECT 1 FROM deleted);
 END;
GO
CREATE OR ALTER VIEW dbo.v_CondicionVigenteAlquiler AS
SELECT da.id_detalle_alquiler,da.id_alquiler,ds.id_recurso,
 COALESCE(c.cantidad_propuesta,dc.cantidad_ofrecida) cantidad,
 COALESCE(c.fecha_inicio_propuesta,dc.fecha_inicio) fecha_inicio,
 COALESCE(c.fecha_fin_propuesta,dc.fecha_fin) fecha_fin,
 dc.tarifa_unitaria,dc.unidades_tiempo_cobrables,dc.id_unidad_cobro
FROM dbo.DetalleAlquiler da JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
OUTER APPLY(SELECT TOP(1) d.cantidad_propuesta,d.fecha_inicio_propuesta,d.fecha_fin_propuesta
 FROM dbo.DetalleSolicitudCambio d JOIN dbo.SolicitudCambio sc ON sc.id_solicitud_cambio=d.id_solicitud_cambio
 WHERE d.id_detalle_alquiler=da.id_detalle_alquiler AND sc.estado='APROBADA' AND sc.fecha_aceptacion_cliente IS NOT NULL AND sc.numero_revision_aplicada IS NOT NULL
 ORDER BY sc.numero_revision_aplicada DESC,sc.id_solicitud_cambio DESC)c;
GO
CREATE OR ALTER VIEW dbo.v_EntregaSaldo AS
SELECT dd.id_detalle_despacho,dd.id_despacho,dd.id_reserva,dd.cantidad_despachada,
 COALESCE(x.devuelta,0) cantidad_devuelta,CONVERT(BIGINT,dd.cantidad_despachada)-COALESCE(x.devuelta,0) pendiente,
 x.ultima_devolucion
FROM dbo.DetalleDespacho dd
OUTER APPLY(SELECT SUM(CONVERT(BIGINT,d.cantidad_recibida)) devuelta,MAX(v.fecha_recepcion) ultima_devolucion
 FROM dbo.DetalleDevolucion d JOIN dbo.Devolucion v ON v.id_devolucion=d.id_devolucion WHERE d.id_detalle_despacho=dd.id_detalle_despacho)x;
GO
CREATE OR ALTER VIEW dbo.v_Liquidacion AS
SELECT a.id_alquiler,
 COALESCE(b.equipos,0) equipos,COALESCE(b.personal,0) personal,COALESCE(co.conceptos,0) conceptos_cotizacion,
 COALESCE(c.cargos,0) cargos_adicionales,COALESCE(j.ajustes,0) ajustes,
 COALESCE(b.equipos,0)+COALESCE(b.personal,0)+COALESCE(co.conceptos,0)+COALESCE(c.cargos,0)+COALESCE(j.ajustes,0) total_vigente,
 COALESCE(p.pagos,0) pagos_recibidos,COALESCE(re.efectivos,0) reembolsos_efectivos,COALESCE(re.pendientes,0) reembolsos_pendientes
FROM dbo.Alquiler a
OUTER APPLY(SELECT SUM(CASE WHEN r.naturaleza='EQUIPO' THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) equipos,
 SUM(CASE WHEN r.naturaleza='PERSONAL' THEN dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables ELSE 0 END) personal
 FROM dbo.DetalleAlquiler da JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
 JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso WHERE da.id_alquiler=a.id_alquiler)b
OUTER APPLY(SELECT SUM(cantidad*valor_unitario) conceptos FROM dbo.ConceptoCotizacion WHERE id_cotizacion=a.id_cotizacion_aceptada)co
OUTER APPLY(SELECT SUM(importe) cargos FROM dbo.CargoAlquiler WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE')c
OUTER APPLY(SELECT SUM(CASE WHEN tipo_ajuste='REDUCCION' THEN -importe ELSE importe END) ajustes FROM dbo.AjusteEconomicoAlquiler WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE')j
OUTER APPLY(SELECT SUM(importe) pagos FROM dbo.Pago WHERE id_alquiler=a.id_alquiler AND estado='VIGENTE')p
OUTER APPLY(SELECT SUM(CASE WHEN estado='EFECTUADO' THEN importe ELSE 0 END) efectivos,SUM(CASE WHEN estado='AUTORIZADO' THEN importe ELSE 0 END) pendientes FROM dbo.Reembolso WHERE id_alquiler=a.id_alquiler)re;
GO
CREATE OR ALTER VIEW dbo.v_ReservaVigente AS
WITH v AS (SELECT *,ROW_NUMBER() OVER(PARTITION BY id_reserva ORDER BY numero_version DESC) rn FROM dbo.VersionReservaEquipo)
SELECT r.id_reserva,r.id_detalle_alquiler,r.id_bodega,v.cantidad_comprometida,v.fecha_inicio,v.fecha_fin,v.estado
FROM dbo.ReservaEquipo r JOIN v ON v.id_reserva=r.id_reserva AND v.rn=1;
GO
CREATE OR ALTER VIEW dbo.v_SaldoFisico AS
SELECT d.id_recurso,d.id_bodega,d.id_condicion,SUM(CONVERT(BIGINT,d.cantidad_variacion)) cantidad
FROM dbo.DetalleMovimientoInventario d GROUP BY d.id_recurso,d.id_bodega,d.id_condicion;
GO
CREATE OR ALTER PROCEDURE operacion.usp_RegistrarCliente
 @Nit VARCHAR(20),@RazonSocial NVARCHAR(200),@Telefono VARCHAR(30),@Correo NVARCHAR(254)=NULL
AS
BEGIN
 SET NOCOUNT ON;SET XACT_ABORT ON;
 IF @Nit IS NULL OR LEN(LTRIM(RTRIM(@Nit)))=0 OR @RazonSocial IS NULL OR LEN(LTRIM(RTRIM(@RazonSocial)))=0 OR @Telefono IS NULL OR LEN(LTRIM(RTRIM(@Telefono)))=0
 THROW 52100,'NIT, razon social y telefono son obligatorios.',1;
 INSERT dbo.Cliente(nit,razon_social,telefono,correo)
 VALUES(LTRIM(RTRIM(@Nit)),LTRIM(RTRIM(@RazonSocial)),LTRIM(RTRIM(@Telefono)),NULLIF(LTRIM(RTRIM(@Correo)),''));
 SELECT CONVERT(INT,SCOPE_IDENTITY()) id_cliente;
END;
GO
CREATE OR ALTER PROCEDURE operacion.usp_RegistrarSolicitud
 @IdCliente INT,@IdObra INT,@Numero VARCHAR(30),@Canal VARCHAR(10),@Lineas NVARCHAR(MAX),@Observaciones NVARCHAR(1000)=NULL
AS
BEGIN
 SET NOCOUNT ON;SET XACT_ABORT ON;
 IF ISJSON(@Lineas)<>1 OR @Lineas IS NULL THROW 52101,'Las lineas deben ser un arreglo JSON valido.',1;
 IF LEFT(LTRIM(@Lineas),1)<>'[' THROW 52102,'Se requiere un arreglo de lineas.',1;
 IF EXISTS(SELECT 1 FROM OPENJSON(@Lineas) WHERE [type]<>5) THROW 52105,'Cada linea debe ser un objeto JSON.',1;
 IF @Numero IS NULL OR LEN(LTRIM(RTRIM(@Numero)))=0 THROW 52106,'Numero de solicitud obligatorio.',1;
 IF NOT EXISTS(SELECT 1 FROM dbo.Cliente WHERE id_cliente=@IdCliente AND activo=1) THROW 52107,'Cliente inexistente o inactivo.',1;
 IF NOT EXISTS(SELECT 1 FROM dbo.Obra WHERE id_obra=@IdObra) THROW 52108,'Obra inexistente.',1;
 IF @Canal IS NULL OR @Canal NOT IN('WEB','WHATSAPP') THROW 52103,'Canal invalido.',1;
 DECLARE @d TABLE(numero_linea INT PRIMARY KEY,id_recurso INT,cantidad INT,inicio DATETIME2(0),fin DATETIME2(0));
 INSERT @d SELECT TRY_CONVERT(INT,j.[key])+1,TRY_CONVERT(INT,JSON_VALUE(j.value,'$.id_recurso')),TRY_CONVERT(INT,JSON_VALUE(j.value,'$.cantidad')),TRY_CONVERT(DATETIME2(0),JSON_VALUE(j.value,'$.fecha_inicio')),TRY_CONVERT(DATETIME2(0),JSON_VALUE(j.value,'$.fecha_fin')) FROM OPENJSON(@Lineas)j;
 IF NOT EXISTS(SELECT 1 FROM @d) OR EXISTS(SELECT 1 FROM @d d LEFT JOIN dbo.Recurso r ON r.id_recurso=d.id_recurso AND r.activo=1 WHERE r.id_recurso IS NULL OR d.cantidad IS NULL OR d.cantidad<=0 OR d.inicio IS NULL OR d.fin IS NULL OR d.fin<=d.inicio)
 THROW 52104,'Las lineas requieren recurso activo, cantidad positiva y periodo valido.',1;
 BEGIN TRY
 BEGIN TRANSACTION;
 INSERT dbo.Solicitud(id_cliente,id_obra,numero_solicitud,canal,observaciones) VALUES(@IdCliente,@IdObra,@Numero,@Canal,@Observaciones);
 DECLARE @id INT=CONVERT(INT,SCOPE_IDENTITY());
 INSERT dbo.DetalleSolicitud(id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada) SELECT @id,id_recurso,numero_linea,cantidad,inicio,fin FROM @d;
 COMMIT;SELECT @id id_solicitud;
 END TRY
 BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK;
 THROW;
 END CATCH;
END;
GO
/* 01: stock as of date, one aggregate per resource/warehouse; separate conditions.
   Reservation quantities are not repeated once for each material condition. */
CREATE OR ALTER PROCEDURE reporte.usp_01_Inventario @Fecha DATETIME2(0)=NULL AS
BEGIN
 SET NOCOUNT ON; SET @Fecha=COALESCE(@Fecha,SYSDATETIME());
 SELECT d.id_recurso,d.id_bodega,d.id_condicion,SUM(CONVERT(BIGINT,d.cantidad_variacion)) cantidad
 INTO #stock FROM dbo.DetalleMovimientoInventario d JOIN dbo.MovimientoInventario m ON m.id_movimiento=d.id_movimiento
 WHERE m.fecha_movimiento<=@Fecha GROUP BY d.id_recurso,d.id_bodega,d.id_condicion;
 ;WITH versiones AS(
 SELECT v.*,ROW_NUMBER() OVER(PARTITION BY id_reserva ORDER BY numero_version DESC) rn
 FROM dbo.VersionReservaEquipo v WHERE fecha_aplicacion<=@Fecha
 ), entregas AS(
 SELECT dd.id_reserva,SUM(CONVERT(BIGINT,dd.cantidad_despachada)) despachada,
 SUM(CONVERT(BIGINT,dd.cantidad_despachada)-COALESCE(v.devuelta,0)) pendiente
 FROM dbo.DetalleDespacho dd JOIN dbo.Despacho d ON d.id_despacho=dd.id_despacho
 OUTER APPLY(SELECT SUM(CONVERT(BIGINT,x.cantidad_recibida)) devuelta FROM dbo.DetalleDevolucion x JOIN dbo.Devolucion y ON y.id_devolucion=x.id_devolucion WHERE x.id_detalle_despacho=dd.id_detalle_despacho AND y.fecha_recepcion<=@Fecha)v
 WHERE d.fecha_salida<=@Fecha GROUP BY dd.id_reserva
 )
 SELECT ds.id_recurso,re.id_bodega,
 SUM(CASE WHEN v.estado='ACTIVA' AND v.fecha_inicio<=@Fecha AND v.fecha_fin>@Fecha AND v.cantidad_comprometida>COALESCE(e.despachada,0) THEN v.cantidad_comprometida-COALESCE(e.despachada,0) ELSE 0 END) reservado,
 SUM(COALESCE(e.pendiente,0)) en_cliente
 INTO #compromiso FROM versiones v JOIN dbo.ReservaEquipo re ON re.id_reserva=v.id_reserva
 JOIN dbo.DetalleAlquiler da ON da.id_detalle_alquiler=re.id_detalle_alquiler
 JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
 JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud
 LEFT JOIN entregas e ON e.id_reserva=v.id_reserva WHERE v.rn=1 GROUP BY ds.id_recurso,re.id_bodega;
 ;WITH claves AS(SELECT id_recurso,id_bodega FROM #stock UNION SELECT id_recurso,id_bodega FROM #compromiso),
 fisico AS(SELECT s.id_recurso,s.id_bodega,SUM(s.cantidad) fisico,SUM(CASE WHEN c.permite_despacho=1 THEN s.cantidad ELSE 0 END) apto,SUM(CASE WHEN c.permite_despacho=0 THEN s.cantidad ELSE 0 END) bloqueado FROM #stock s JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion GROUP BY s.id_recurso,s.id_bodega)
 SELECT r.codigo,r.nombre,b.nombre bodega,COALESCE(f.fisico,0) cantidad_fisica,COALESCE(f.apto,0) apto_en_bodega,
 COALESCE(f.bloqueado,0) no_apto_en_bodega,COALESCE(c.reservado,0) reservado_pendiente_despacho,COALESCE(c.en_cliente,0) en_cliente,
 CASE WHEN COALESCE(f.apto,0)>COALESCE(c.reservado,0) THEN COALESCE(f.apto,0)-COALESCE(c.reservado,0) ELSE 0 END disponible_estimado
 FROM claves k JOIN dbo.Recurso r ON r.id_recurso=k.id_recurso JOIN dbo.Bodega b ON b.id_bodega=k.id_bodega LEFT JOIN fisico f ON f.id_recurso=k.id_recurso AND f.id_bodega=k.id_bodega LEFT JOIN #compromiso c ON c.id_recurso=k.id_recurso AND c.id_bodega=k.id_bodega ORDER BY r.nombre,b.nombre;
 SELECT r.nombre recurso,b.nombre bodega,c.nombre condicion,c.permite_despacho,s.cantidad FROM #stock s JOIN dbo.Recurso r ON r.id_recurso=s.id_recurso JOIN dbo.Bodega b ON b.id_bodega=s.id_bodega JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion ORDER BY r.nombre,b.nombre,c.nombre;
END;
GO
/* 02: peak simultaneous, not SUM of every reservation touching the whole range.
   Uses current physical stock and does not assume future returns are inspected.
   A reporting estimate, NOT a concurrent booking authorization mechanism. */
CREATE OR ALTER PROCEDURE reporte.usp_02_DisponibilidadFutura @Inicio DATETIME2(0),@Fin DATETIME2(0),@IdRecurso INT=NULL,@Cantidad INT=1 AS
BEGIN
 SET NOCOUNT ON;
 IF @Inicio IS NULL OR @Fin IS NULL OR @Fin<=@Inicio OR @Cantidad IS NULL OR @Cantidad<=0 THROW 52000,'Periodo o cantidad invalida.',1;
 ;WITH compromisos AS(
 SELECT ca.id_recurso,v.fecha_inicio,v.fecha_fin,v.cantidad_comprometida-COALESCE(x.despachada,0) cantidad
 FROM dbo.v_ReservaVigente v JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=v.id_detalle_alquiler
 OUTER APPLY(SELECT SUM(CONVERT(BIGINT,cantidad_despachada)) despachada FROM dbo.DetalleDespacho WHERE id_reserva=v.id_reserva)x
 WHERE v.estado='ACTIVA' AND v.fecha_inicio<@Fin AND v.fecha_fin>@Inicio AND v.cantidad_comprometida>COALESCE(x.despachada,0)
 ), puntos AS(SELECT id_recurso,@Inicio fecha FROM compromisos UNION SELECT id_recurso,fecha_inicio FROM compromisos WHERE fecha_inicio>@Inicio),
 cargas AS(SELECT p.id_recurso,p.fecha,SUM(c.cantidad) cantidad FROM puntos p JOIN compromisos c ON c.id_recurso=p.id_recurso AND c.fecha_inicio<=p.fecha AND c.fecha_fin>p.fecha GROUP BY p.id_recurso,p.fecha),
 pico AS(SELECT id_recurso,MAX(cantidad) cantidad FROM cargas GROUP BY id_recurso),
 aptos AS(SELECT s.id_recurso,SUM(s.cantidad) cantidad FROM dbo.v_SaldoFisico s JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion WHERE c.permite_despacho=1 GROUP BY s.id_recurso),
 retornos AS(SELECT ca.id_recurso,SUM(es.pendiente) cantidad FROM dbo.v_EntregaSaldo es JOIN dbo.ReservaEquipo re ON re.id_reserva=es.id_reserva JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler WHERE ca.fecha_fin<=@Inicio AND es.pendiente>0 GROUP BY ca.id_recurso)
 SELECT r.id_recurso,r.nombre,COALESCE(a.cantidad,0) stock_apto_actual,COALESCE(p.cantidad,0) pico_comprometido_pendiente_despacho,
 x.disponible disponibilidad_conservadora,CASE WHEN @Cantidad>x.disponible THEN @Cantidad-x.disponible ELSE 0 END faltante,
 COALESCE(d.cantidad,0) devoluciones_previstas_aun_no_recibidas,
 CONVERT(BIT,CASE WHEN COALESCE(d.cantidad,0)>0 AND @Cantidad>x.disponible THEN 1 ELSE 0 END) depende_de_devoluciones
 FROM dbo.Recurso r LEFT JOIN aptos a ON a.id_recurso=r.id_recurso LEFT JOIN pico p ON p.id_recurso=r.id_recurso LEFT JOIN retornos d ON d.id_recurso=r.id_recurso
 CROSS APPLY(SELECT CASE WHEN COALESCE(a.cantidad,0)>COALESCE(p.cantidad,0) THEN COALESCE(a.cantidad,0)-COALESCE(p.cantidad,0) ELSE 0 END disponible)x
 WHERE r.naturaleza='EQUIPO' AND r.activo=1 AND (@IdRecurso IS NULL OR r.id_recurso=@IdRecurso);
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_03_Cotizaciones AS
BEGIN SET NOCOUNT ON;
SELECT c.id_cotizacion,c.numero_version,s.numero_solicitud,cl.razon_social,o.nombre obra,c.estado,c.fecha_emision,c.fecha_vencimiento,c.motivo_rechazo,
 dc.numero_linea,r.nombre recurso,dc.cantidad_ofrecida,dc.fecha_inicio,dc.fecha_fin,dc.tarifa_unitaria,dc.unidades_tiempo_cobrables,dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables valor_linea
FROM dbo.Cotizacion c JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente JOIN dbo.Obra o ON o.id_obra=s.id_obra
LEFT JOIN dbo.DetalleCotizacion dc ON dc.id_cotizacion=c.id_cotizacion LEFT JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud LEFT JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso;
SELECT COUNT(*) solicitudes_cotizadas,SUM(CONVERT(INT,convertida)) solicitudes_convertidas,
 CAST(100.0*SUM(CONVERT(INT,convertida))/NULLIF(COUNT(*),0) AS DECIMAL(6,2)) porcentaje_conversion
FROM (SELECT c.id_solicitud,CONVERT(BIT,MAX(CASE WHEN a.id_alquiler IS NULL THEN 0 ELSE 1 END)) convertida FROM dbo.Cotizacion c LEFT JOIN dbo.Alquiler a ON a.id_cotizacion_aceptada=c.id_cotizacion GROUP BY c.id_solicitud)x;
SELECT c.id_cotizacion,co.concepto,co.cantidad,co.valor_unitario,co.cantidad*co.valor_unitario total_concepto FROM dbo.Cotizacion c JOIN dbo.ConceptoCotizacion co ON co.id_cotizacion=c.id_cotizacion;
SELECT c.id_cotizacion,s.numero_solicitud,ds.numero_linea,r.nombre recurso,ds.cantidad cantidad_solicitada,ds.fecha_inicio_solicitada,ds.fecha_fin_solicitada FROM dbo.Cotizacion c JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.DetalleSolicitud ds ON ds.id_solicitud=s.id_solicitud JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso;
END;
GO
/* 04: includes late returns already completed, not only units still outstanding. */
CREATE OR ALTER PROCEDURE reporte.usp_04_ActivosVencidos @Fecha DATETIME2(0)=NULL AS
BEGIN
 SET NOCOUNT ON;SET @Fecha=COALESCE(@Fecha,SYSDATETIME());
 SELECT a.numero_alquiler,a.estado_operativo,cl.razon_social,o.nombre obra,r.nombre recurso,r.naturaleza,
 ca.cantidad,ca.fecha_inicio,ca.fecha_fin,COALESCE(x.pendiente,0) pendiente_equipo,
 x.ultima_devolucion,
 CASE WHEN r.naturaleza='EQUIPO' AND limite.fecha_fin_retraso>ca.fecha_fin THEN CEILING(DATEDIFF_BIG(SECOND,ca.fecha_fin,limite.fecha_fin_retraso)/86400.0) ELSE 0 END bloques_24h_retraso,
 (SELECT COUNT(*) FROM dbo.SolicitudCambio sc WHERE sc.id_alquiler=a.id_alquiler AND sc.estado='APROBADA' AND sc.fecha_aceptacion_cliente IS NOT NULL AND sc.numero_revision_aplicada IS NOT NULL) cambios_aplicados
 FROM dbo.Alquiler a JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente JOIN dbo.Obra o ON o.id_obra=s.id_obra JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_alquiler=a.id_alquiler JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
 OUTER APPLY(SELECT SUM(CONVERT(BIGINT,dd.cantidad_despachada)-COALESCE(v.devuelta,0)) pendiente,MAX(v.ultima) ultima_devolucion
 FROM dbo.ReservaEquipo re JOIN dbo.DetalleDespacho dd ON dd.id_reserva=re.id_reserva JOIN dbo.Despacho des ON des.id_despacho=dd.id_despacho
 OUTER APPLY(SELECT SUM(CONVERT(BIGINT,dv.cantidad_recibida)) devuelta,MAX(de.fecha_recepcion) ultima FROM dbo.DetalleDevolucion dv JOIN dbo.Devolucion de ON de.id_devolucion=dv.id_devolucion WHERE dv.id_detalle_despacho=dd.id_detalle_despacho AND de.fecha_recepcion<=@Fecha)v
 WHERE re.id_detalle_alquiler=ca.id_detalle_alquiler AND des.fecha_salida<=@Fecha)x
 CROSS APPLY(SELECT CASE WHEN COALESCE(x.pendiente,0)>0 THEN @Fecha ELSE x.ultima_devolucion END fecha_fin_retraso)limite
 WHERE a.fecha_confirmacion<=@Fecha AND (a.fecha_cierre_operativo IS NULL OR a.fecha_cierre_operativo>@Fecha OR limite.fecha_fin_retraso>ca.fecha_fin);
 SELECT a.numero_alquiler,e.nombre empleado,r.nombre servicio,ap.fecha_inicio,ap.fecha_fin,ap.estado,rs.fecha_hora_inicio_real,rs.fecha_hora_fin_real,rs.estado estado_registro
 FROM dbo.AsignacionPersonal ap JOIN dbo.Empleado e ON e.id_empleado=ap.id_empleado JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=ap.id_detalle_alquiler JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso LEFT JOIN dbo.RegistroServicioPersonal rs ON rs.id_asignacion=ap.id_asignacion;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_05_DespachosDevoluciones AS
BEGIN SET NOCOUNT ON;
SELECT a.numero_alquiler,o.nombre obra,ca.id_detalle_alquiler,r.nombre recurso,ca.cantidad contratada,
 COALESCE(d.despachada,0) despachada,COALESCE(d.devuelta,0) devuelta,COALESCE(d.pendiente,0) pendiente_devolucion,
 CASE WHEN ca.cantidad>COALESCE(d.despachada,0) THEN ca.cantidad-COALESCE(d.despachada,0) ELSE 0 END pendiente_despacho
FROM dbo.v_CondicionVigenteAlquiler ca JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Obra o ON o.id_obra=s.id_obra JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
OUTER APPLY(SELECT SUM(CONVERT(BIGINT,e.cantidad_despachada)) despachada,SUM(e.cantidad_devuelta) devuelta,SUM(e.pendiente) pendiente FROM dbo.ReservaEquipo re JOIN dbo.v_EntregaSaldo e ON e.id_reserva=re.id_reserva WHERE re.id_detalle_alquiler=ca.id_detalle_alquiler)d WHERE r.naturaleza='EQUIPO';
SELECT d.id_despacho,d.numero_despacho,d.fecha_salida,d.id_empleado_entrega,ce.nombre_receptor,ce.fecha_entrega,x.id_documento,doc.nombre_archivo
FROM dbo.Despacho d LEFT JOIN dbo.ConstanciaEntrega ce ON ce.id_despacho=d.id_despacho LEFT JOIN dbo.EntregaDocumento x ON x.id_constancia=ce.id_constancia LEFT JOIN dbo.Documento doc ON doc.id_documento=x.id_documento;
SELECT v.id_devolucion,v.numero_devolucion,v.fecha_recepcion,v.id_empleado_receptor,d.id_detalle_despacho,d.cantidad_recibida FROM dbo.Devolucion v JOIN dbo.DetalleDevolucion d ON d.id_devolucion=v.id_devolucion;
SELECT v.numero_devolucion,v.fecha_recepcion,e.nombre receptor,d.nombre_archivo,d.ubicacion_archivo FROM dbo.Devolucion v JOIN dbo.Empleado e ON e.id_empleado=v.id_empleado_receptor LEFT JOIN dbo.DevolucionDocumento x ON x.id_devolucion=v.id_devolucion LEFT JOIN dbo.Documento d ON d.id_documento=x.id_documento;
SELECT dd.id_detalle_despacho,dd.observaciones_salida,d.nombre_archivo,d.ubicacion_archivo FROM dbo.DetalleDespacho dd LEFT JOIN dbo.DespachoDetalleDocumento x ON x.id_detalle_despacho=dd.id_detalle_despacho LEFT JOIN dbo.Documento d ON d.id_documento=x.id_documento;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_06_Utilizacion @Inicio DATETIME2(0),@Fin DATETIME2(0) AS
BEGIN SET NOCOUNT ON;
-- Utilization is historical; do not count days that have not elapsed.
IF @Fin>SYSDATETIME() SET @Fin=SYSDATETIME();
IF @Inicio IS NULL OR @Fin IS NULL OR @Fin<=@Inicio THROW 52001,'Periodo invalido.',1;
;WITH stock0 AS (
 SELECT d.id_recurso,SUM(CONVERT(BIGINT,d.cantidad_variacion)) cantidad FROM dbo.DetalleMovimientoInventario d JOIN dbo.MovimientoInventario m ON m.id_movimiento=d.id_movimiento JOIN dbo.CondicionMaterial c ON c.id_condicion=d.id_condicion WHERE m.fecha_movimiento<@Inicio AND c.permite_despacho=1 GROUP BY d.id_recurso
), cambios AS (
 SELECT d.id_recurso,m.fecha_movimiento,SUM(CONVERT(BIGINT,d.cantidad_variacion)) delta FROM dbo.DetalleMovimientoInventario d JOIN dbo.MovimientoInventario m ON m.id_movimiento=d.id_movimiento JOIN dbo.CondicionMaterial c ON c.id_condicion=d.id_condicion WHERE m.fecha_movimiento>=@Inicio AND m.fecha_movimiento<@Fin AND c.permite_despacho=1 GROUP BY d.id_recurso,m.fecha_movimiento
), tiempo AS (
 SELECT r.id_recurso,@Inicio fecha,COALESCE(s.cantidad,0) delta FROM dbo.Recurso r LEFT JOIN stock0 s ON s.id_recurso=r.id_recurso WHERE r.naturaleza='EQUIPO'
 UNION ALL SELECT id_recurso,fecha_movimiento,delta FROM cambios
), acumulado AS (
 SELECT id_recurso,fecha,SUM(delta) OVER(PARTITION BY id_recurso ORDER BY fecha ROWS UNBOUNDED PRECEDING) saldo,LEAD(fecha,1,@Fin) OVER(PARTITION BY id_recurso ORDER BY fecha) hasta FROM (SELECT id_recurso,fecha,SUM(delta) delta FROM tiempo GROUP BY id_recurso,fecha)t
), libres AS (SELECT id_recurso,SUM(saldo*DATEDIFF_BIG(SECOND,fecha,hasta)/86400.0) dias_libres FROM acumulado GROUP BY id_recurso),
intervalos AS (
 SELECT ca.id_recurso,des.fecha_salida inicio,dev.fecha_recepcion fin,dd.cantidad_recibida cantidad FROM dbo.DetalleDevolucion dd JOIN dbo.Devolucion dev ON dev.id_devolucion=dd.id_devolucion JOIN dbo.v_EntregaSaldo es ON es.id_detalle_despacho=dd.id_detalle_despacho JOIN dbo.Despacho des ON des.id_despacho=es.id_despacho JOIN dbo.ReservaEquipo re ON re.id_reserva=es.id_reserva JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
 UNION ALL SELECT ca.id_recurso,des.fecha_salida,@Fin,es.pendiente FROM dbo.v_EntregaSaldo es JOIN dbo.Despacho des ON des.id_despacho=es.id_despacho JOIN dbo.ReservaEquipo re ON re.id_reserva=es.id_reserva JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler WHERE es.pendiente>0
), uso AS (SELECT id_recurso,SUM(cantidad*DATEDIFF_BIG(SECOND,CASE WHEN inicio<@Inicio THEN @Inicio ELSE inicio END,CASE WHEN fin>@Fin THEN @Fin ELSE fin END)/86400.0) dias_uso FROM intervalos WHERE inicio<@Fin AND fin>@Inicio GROUP BY id_recurso)
SELECT r.id_recurso,r.nombre,COALESCE(u.dias_uso,0) unidades_dia_alquiladas,COALESCE(l.dias_libres,0) unidades_dia_aptas_en_bodega,
 COALESCE(u.dias_uso,0)+COALESCE(l.dias_libres,0) capacidad_alquilable_unidades_dia,
 CAST(100.0*COALESCE(u.dias_uso,0)/NULLIF(COALESCE(u.dias_uso,0)+COALESCE(l.dias_libres,0),0) AS DECIMAL(8,2)) porcentaje_utilizacion
FROM dbo.Recurso r LEFT JOIN libres l ON l.id_recurso=r.id_recurso LEFT JOIN uso u ON u.id_recurso=r.id_recurso WHERE r.naturaleza='EQUIPO';
-- Tiempos no aptos por condicion: separados de la capacidad alquilable.
;WITH puntos AS (
 SELECT r.id_recurso,c.id_condicion,@Inicio fecha,COALESCE((SELECT SUM(CONVERT(BIGINT,d.cantidad_variacion)) FROM dbo.DetalleMovimientoInventario d JOIN dbo.MovimientoInventario m ON m.id_movimiento=d.id_movimiento WHERE d.id_recurso=r.id_recurso AND d.id_condicion=c.id_condicion AND m.fecha_movimiento<@Inicio),0) delta FROM dbo.Recurso r CROSS JOIN dbo.CondicionMaterial c WHERE r.naturaleza='EQUIPO' AND c.permite_despacho=0
 UNION ALL SELECT d.id_recurso,d.id_condicion,m.fecha_movimiento,SUM(CONVERT(BIGINT,d.cantidad_variacion)) FROM dbo.DetalleMovimientoInventario d JOIN dbo.MovimientoInventario m ON m.id_movimiento=d.id_movimiento JOIN dbo.CondicionMaterial c ON c.id_condicion=d.id_condicion WHERE c.permite_despacho=0 AND m.fecha_movimiento>=@Inicio AND m.fecha_movimiento<@Fin GROUP BY d.id_recurso,d.id_condicion,m.fecha_movimiento
), a AS (SELECT id_recurso,id_condicion,fecha,SUM(delta) OVER(PARTITION BY id_recurso,id_condicion ORDER BY fecha ROWS UNBOUNDED PRECEDING) saldo,LEAD(fecha,1,@Fin) OVER(PARTITION BY id_recurso,id_condicion ORDER BY fecha) hasta FROM(SELECT id_recurso,id_condicion,fecha,SUM(delta) delta FROM puntos GROUP BY id_recurso,id_condicion,fecha)t)
SELECT a.id_recurso,c.nombre condicion,SUM(saldo*DATEDIFF_BIG(SECOND,fecha,hasta)/86400.0) unidades_dia_bloqueadas FROM a JOIN dbo.CondicionMaterial c ON c.id_condicion=a.id_condicion GROUP BY a.id_recurso,c.nombre;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_07_Liquidacion @IdAlquiler INT=NULL AS
BEGIN SET NOCOUNT ON;
SELECT a.numero_alquiler,l.* FROM dbo.v_Liquidacion l JOIN dbo.Alquiler a ON a.id_alquiler=l.id_alquiler WHERE @IdAlquiler IS NULL OR l.id_alquiler=@IdAlquiler;
SELECT da.id_alquiler,r.nombre,r.naturaleza,dc.cantidad_ofrecida,dc.tarifa_unitaria,dc.unidades_tiempo_cobrables,dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables valor_inicial FROM dbo.DetalleAlquiler da JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=dc.id_detalle_solicitud JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso WHERE @IdAlquiler IS NULL OR da.id_alquiler=@IdAlquiler;
SELECT id_alquiler,concepto,importe,justificacion,fecha_autorizacion FROM dbo.CargoAlquiler WHERE estado='VIGENTE' AND (@IdAlquiler IS NULL OR id_alquiler=@IdAlquiler);
SELECT co.id_cotizacion,co.concepto,co.descripcion,co.cantidad,co.valor_unitario,co.cantidad*co.valor_unitario importe FROM dbo.Alquiler a JOIN dbo.ConceptoCotizacion co ON co.id_cotizacion=a.id_cotizacion_aceptada WHERE @IdAlquiler IS NULL OR a.id_alquiler=@IdAlquiler;
SELECT j.id_alquiler,j.tipo_ajuste,j.importe,j.motivo,j.estado,j.fecha_autorizacion FROM dbo.AjusteEconomicoAlquiler j WHERE @IdAlquiler IS NULL OR j.id_alquiler=@IdAlquiler;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_08_PagosSaldos @IdAlquiler INT=NULL AS
BEGIN SET NOCOUNT ON;
SELECT a.numero_alquiler,cl.razon_social,l.total_vigente,l.pagos_recibidos,l.reembolsos_efectivos,l.pagos_recibidos-l.reembolsos_efectivos pagos_netos,
 CASE WHEN l.total_vigente>l.pagos_recibidos-l.reembolsos_efectivos THEN l.total_vigente-(l.pagos_recibidos-l.reembolsos_efectivos) ELSE 0 END saldo_pendiente,
 CASE WHEN l.pagos_recibidos-l.reembolsos_efectivos>l.total_vigente THEN l.pagos_recibidos-l.reembolsos_efectivos-l.total_vigente ELSE 0 END excedente,l.reembolsos_pendientes
FROM dbo.v_Liquidacion l JOIN dbo.Alquiler a ON a.id_alquiler=l.id_alquiler JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente WHERE @IdAlquiler IS NULL OR l.id_alquiler=@IdAlquiler;
SELECT id_pago,id_alquiler,fecha_pago,importe,medio_pago,referencia_transaccion,estado FROM dbo.Pago WHERE @IdAlquiler IS NULL OR id_alquiler=@IdAlquiler;
SELECT id_reembolso,id_alquiler,importe,estado,fecha_autorizacion,fecha_efectiva FROM dbo.Reembolso WHERE @IdAlquiler IS NULL OR id_alquiler=@IdAlquiler;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_09_ValoresRecaudos @Inicio DATETIME2(0),@Fin DATETIME2(0) AS
BEGIN SET NOCOUNT ON;IF @Inicio IS NULL OR @Fin IS NULL OR @Fin<=@Inicio THROW 52002,'Periodo invalido.',1;
SELECT cl.id_cliente,cl.razon_social,o.id_obra,o.nombre obra,a.numero_alquiler,l.equipos,l.personal,l.conceptos_cotizacion,l.cargos_adicionales,l.ajustes,l.total_vigente
FROM dbo.Alquiler a JOIN dbo.v_Liquidacion l ON l.id_alquiler=a.id_alquiler JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente JOIN dbo.Obra o ON o.id_obra=s.id_obra WHERE a.fecha_confirmacion>=@Inicio AND a.fecha_confirmacion<@Fin;
;WITH movimientos AS (SELECT id_alquiler,fecha_pago fecha,importe monto FROM dbo.Pago WHERE estado='VIGENTE' UNION ALL SELECT id_alquiler,fecha_efectiva,-importe FROM dbo.Reembolso WHERE estado='EFECTUADO')
SELECT cl.id_cliente,cl.razon_social,o.id_obra,o.nombre obra,SUM(CASE WHEN m.monto>0 THEN m.monto ELSE 0 END) pagos,SUM(CASE WHEN m.monto<0 THEN -m.monto ELSE 0 END) reembolsos,SUM(m.monto) recaudo_neto
FROM movimientos m JOIN dbo.Alquiler a ON a.id_alquiler=m.id_alquiler JOIN dbo.Cotizacion c ON c.id_cotizacion=a.id_cotizacion_aceptada JOIN dbo.Solicitud s ON s.id_solicitud=c.id_solicitud JOIN dbo.Cliente cl ON cl.id_cliente=s.id_cliente JOIN dbo.Obra o ON o.id_obra=s.id_obra WHERE m.fecha>=@Inicio AND m.fecha<@Fin GROUP BY cl.id_cliente,cl.razon_social,o.id_obra,o.nombre;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_10_Incidencias AS
BEGIN
 SET NOCOUNT ON;
 SELECT i.id_incidencia,a.numero_alquiler,r.nombre recurso,i.tipo,i.cantidad_afectada,i.fecha_registro,i.descripcion,i.estado,i.resolucion,i.fecha_resolucion,i.costo_estimado,i.responsabilidad_acordada,i.fecha_evaluacion,
 COALESCE(c.cargo,0) cargo_autorizado,i.id_usuario_registro
 FROM dbo.IncidenciaAlquiler i JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=i.id_detalle_alquiler JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
 OUTER APPLY(SELECT SUM(c.importe) cargo FROM dbo.CargoIncidencia ci JOIN dbo.CargoAlquiler c ON c.id_cargo=ci.id_cargo WHERE ci.id_incidencia=i.id_incidencia AND c.estado='VIGENTE')c;
 SELECT x.id_incidencia,d.id_documento,d.nombre_archivo,d.tipo_archivo FROM dbo.IncidenciaDocumento x JOIN dbo.Documento d ON d.id_documento=x.id_documento;
 SELECT ii.id_incidencia,di.id_detalle_devolucion,di.cantidad_revisada,c.nombre condicion_resultante,dd.observaciones_salida FROM dbo.IncidenciaInspeccion ii JOIN dbo.DetalleInspeccion di ON di.id_detalle_inspeccion=ii.id_detalle_inspeccion JOIN dbo.CondicionMaterial c ON c.id_condicion=di.id_condicion_resultante JOIN dbo.DetalleDevolucion dv ON dv.id_detalle_devolucion=di.id_detalle_devolucion JOIN dbo.DetalleDespacho dd ON dd.id_detalle_despacho=dv.id_detalle_despacho;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_11_InspeccionesBloqueos AS
BEGIN SET NOCOUNT ON;
SELECT r.nombre recurso,b.nombre bodega,c.nombre condicion,s.cantidad FROM dbo.v_SaldoFisico s JOIN dbo.Recurso r ON r.id_recurso=s.id_recurso JOIN dbo.Bodega b ON b.id_bodega=s.id_bodega JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion WHERE c.permite_despacho=0 AND s.cantidad>0;
SELECT a.numero_alquiler,d.id_detalle_devolucion,v.fecha_recepcion,d.cantidad_recibida,COALESCE(x.revisada,0) revisada,d.cantidad_recibida-COALESCE(x.revisada,0) pendiente_inspeccion
FROM dbo.DetalleDevolucion d JOIN dbo.Devolucion v ON v.id_devolucion=d.id_devolucion JOIN dbo.Alquiler a ON a.id_alquiler=v.id_alquiler OUTER APPLY(SELECT SUM(cantidad_revisada) revisada FROM dbo.DetalleInspeccion WHERE id_detalle_devolucion=d.id_detalle_devolucion)x;
SELECT i.id_inspeccion,i.fecha_inspeccion,i.id_empleado_inspector,d.id_detalle_devolucion,d.cantidad_revisada,c.nombre condicion_resultante FROM dbo.Inspeccion i JOIN dbo.DetalleInspeccion d ON d.id_inspeccion=i.id_inspeccion JOIN dbo.CondicionMaterial c ON c.id_condicion=d.id_condicion_resultante;
SELECT rm.id_revision_material,rm.id_recurso,rm.id_bodega,rm.fecha_revision,rm.cantidad,co.nombre origen,cd.nombre destino,cd.permite_despacho habilitado,rm.id_empleado_revisor FROM dbo.RevisionMaterial rm JOIN dbo.CondicionMaterial co ON co.id_condicion=rm.id_condicion_origen JOIN dbo.CondicionMaterial cd ON cd.id_condicion=rm.id_condicion_destino;
SELECT a.numero_alquiler,r.nombre recurso,b.nombre bodega,dev.fecha_recepcion,ins.fecha_inspeccion,e.nombre inspector,di.cantidad_revisada,cm.nombre condicion_resultante,cm.permite_despacho habilitado_por_inspeccion,doc.nombre_archivo evidencia
FROM dbo.DetalleInspeccion di JOIN dbo.Inspeccion ins ON ins.id_inspeccion=di.id_inspeccion JOIN dbo.Empleado e ON e.id_empleado=ins.id_empleado_inspector JOIN dbo.DetalleDevolucion dd ON dd.id_detalle_devolucion=di.id_detalle_devolucion JOIN dbo.Devolucion dev ON dev.id_devolucion=dd.id_devolucion JOIN dbo.Alquiler a ON a.id_alquiler=dev.id_alquiler JOIN dbo.DetalleDespacho des ON des.id_detalle_despacho=dd.id_detalle_despacho JOIN dbo.ReservaEquipo re ON re.id_reserva=des.id_reserva JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso JOIN dbo.Bodega b ON b.id_bodega=dd.id_bodega_recepcion JOIN dbo.CondicionMaterial cm ON cm.id_condicion=di.id_condicion_resultante LEFT JOIN dbo.InspeccionDetalleDocumento x ON x.id_detalle_inspeccion=di.id_detalle_inspeccion LEFT JOIN dbo.Documento doc ON doc.id_documento=x.id_documento;
SELECT rm.id_revision_material,r.nombre recurso,rm.fecha_revision,e.nombre revisor,cd.nombre condicion_destino,cd.permite_despacho habilitado,doc.nombre_archivo evidencia FROM dbo.RevisionMaterial rm JOIN dbo.Recurso r ON r.id_recurso=rm.id_recurso JOIN dbo.Empleado e ON e.id_empleado=rm.id_empleado_revisor JOIN dbo.CondicionMaterial cd ON cd.id_condicion=rm.id_condicion_destino LEFT JOIN dbo.RevisionMaterialDocumento x ON x.id_revision_material=rm.id_revision_material LEFT JOIN dbo.Documento doc ON doc.id_documento=x.id_documento;
END;
GO
CREATE OR ALTER PROCEDURE reporte.usp_12_DemandaNoAtendida @Inicio DATETIME2(0),@Fin DATETIME2(0) AS
BEGIN
 SET NOCOUNT ON;
 IF @Inicio IS NULL OR @Fin IS NULL OR @Fin<=@Inicio THROW 52003,'Periodo invalido.',1;
 /* Latest evaluation WITHIN the requested period, not the latest of all time. */
 ;WITH ev AS(SELECT *,ROW_NUMBER() OVER(PARTITION BY id_solicitud ORDER BY fecha_evaluacion DESC,id_evaluacion DESC) rn FROM dbo.EvaluacionDisponibilidad WHERE fecha_evaluacion>=@Inicio AND fecha_evaluacion<@Fin)
 SELECT s.numero_solicitud,r.id_recurso,r.nombre recurso,r.naturaleza,d.cantidad_solicitada_evaluada,d.cantidad_disponible,
 d.cantidad_solicitada_evaluada-d.cantidad_disponible faltante,d.fecha_inicio_evaluada,d.fecha_fin_evaluada,d.depende_de_devoluciones,
 d.motivo_no_atencion,d.alternativa_propuesta,d.decision_cliente,d.fecha_decision_cliente,s.estado
 INTO #demanda FROM ev JOIN dbo.Solicitud s ON s.id_solicitud=ev.id_solicitud JOIN dbo.DetalleEvaluacionDisponibilidad d ON d.id_evaluacion=ev.id_evaluacion JOIN dbo.DetalleSolicitud ds ON ds.id_detalle_solicitud=d.id_detalle_solicitud JOIN dbo.Recurso r ON r.id_recurso=ds.id_recurso WHERE ev.rn=1 AND d.cantidad_disponible<d.cantidad_solicitada_evaluada;
 SELECT * FROM #demanda ORDER BY numero_solicitud,recurso;
 SELECT id_recurso,recurso,naturaleza,SUM(CONVERT(BIGINT,faltante)) faltante_total,COUNT(DISTINCT numero_solicitud) solicitudes FROM #demanda GROUP BY id_recurso,recurso,naturaleza;
END;
GO
