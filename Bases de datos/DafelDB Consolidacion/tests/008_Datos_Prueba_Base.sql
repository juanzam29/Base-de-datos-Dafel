USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF EXISTS(SELECT 1 FROM dbo.Recurso WHERE codigo='DAFEL-DEMO-AND')
BEGIN
    PRINT N'Datos DAFEL de demostracion ya cargados.';
    RETURN;
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE
        @CategoriaEquipo INT,
        @CategoriaPersonal INT,
        @RecursoEquipo INT,
        @RecursoPersonal INT,
        @UnidadEquipo INT,
        @UnidadPersonal INT,
        @Bodega INT,
        @CondicionApto INT,
        @TipoInicial INT,
        @Cliente INT,
        @Obra INT,
        @EmpleadoAdmin INT,
        @EmpleadoOperario INT,
        @UsuarioAdmin INT,
        @RolGerencia INT,
        @Solicitud INT,
        @DetalleSolicitudEquipo INT,
        @DetalleSolicitudPersonal INT,
        @Cotizacion INT,
        @DetalleCotizacionEquipo INT,
        @DetalleCotizacionPersonal INT,
        @Alquiler INT,
        @DetalleAlquilerEquipo INT,
        @MovimientoInicial INT,
        @Incidencia INT,
        @Cargo INT;

    INSERT dbo.Categoria(nombre,descripcion,activo)
    VALUES(N'Equipos Dafel',N'Equipos para alquiler en la demostracion academica.',1);
    SET @CategoriaEquipo=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Categoria(nombre,descripcion,activo)
    VALUES(N'Personal Dafel',N'Servicios de personal en la demostracion academica.',1);
    SET @CategoriaPersonal=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Recurso(id_categoria,codigo,nombre,descripcion,naturaleza,activo)
    VALUES(@CategoriaEquipo,'DAFEL-DEMO-AND',N'Andamio multidireccional',N'Equipo ficticio para pruebas.','EQUIPO',1);
    SET @RecursoEquipo=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Recurso(id_categoria,codigo,nombre,descripcion,naturaleza,activo)
    VALUES(@CategoriaPersonal,'DAFEL-DEMO-OP',N'Operario de montaje',N'Servicio ficticio para pruebas.','PERSONAL',1);
    SET @RecursoPersonal=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.UnidadCobro(nombre,descripcion)
    VALUES(N'BLOQUE_24_HORAS',N'Bloque iniciado de veinticuatro horas.');
    SET @UnidadEquipo=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.UnidadCobro(nombre,descripcion)
    VALUES(N'JORNADA',N'Jornada de personal acordada.');
    SET @UnidadPersonal=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.TarifaRecurso(id_recurso,id_unidad_cobro,valor_unitario,vigencia_desde,vigencia_hasta)
    VALUES
        (@RecursoEquipo,@UnidadEquipo,70000,'2026-01-01',NULL),
        (@RecursoPersonal,@UnidadPersonal,100000,'2026-01-01',NULL);

    INSERT dbo.Bodega(nombre,direccion,activo)
    VALUES(N'Bodega principal Dafel',N'Bogota - ubicacion ficticia',1);
    SET @Bodega=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.CondicionMaterial(nombre,permite_despacho)
    VALUES(N'APTO',1);
    SET @CondicionApto=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.CondicionMaterial(nombre,permite_despacho)
    VALUES
        (N'PENDIENTE_INSPECCION',0),
        (N'DANADO',0),
        (N'EN_REPARACION',0),
        (N'RETIRADO',0);

    INSERT dbo.TipoMovimiento(nombre,descripcion)
    VALUES(N'INICIAL',N'Ingreso de saldo inicial para pruebas.');
    SET @TipoInicial=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.TipoMovimiento(nombre,descripcion)
    VALUES
        (N'DESPACHO',N'Salida fisica por despacho.'),
        (N'DEVOLUCION',N'Retorno fisico pendiente de inspeccion.'),
        (N'INSPECCION',N'Reclasificacion posterior a inspeccion.'),
        (N'REVISION',N'Reclasificacion por revision de material.');

    INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
    VALUES('CC','1000000001',N'Daniel Demo Dafel','3000000001',1);
    SET @EmpleadoAdmin=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
    VALUES('CC','1000000002',N'Operario Demo Dafel','3000000002',1);
    SET @EmpleadoOperario=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.EmpleadoServicio(id_empleado,id_recurso)
    VALUES(@EmpleadoOperario,@RecursoPersonal);

    INSERT dbo.Usuario(id_empleado,nombre_usuario,hash_contrasena,activo)
    VALUES(@EmpleadoAdmin,N'daniel.demo',
           '8F14E45FCEEA167A5A36DEDD4BEA2543A12B32DF8190C71C1D41B5C76F69D808',1);
    SET @UsuarioAdmin=CONVERT(INT,SCOPE_IDENTITY());

    EXEC sys.sp_set_session_context @key=N'id_usuario',@value=@UsuarioAdmin;

    INSERT dbo.Rol(nombre,descripcion)
    VALUES(N'GERENCIA',N'Perfil de aplicacion para autorizaciones comerciales.');
    SET @RolGerencia=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.UsuarioRol(id_usuario,id_rol) VALUES(@UsuarioAdmin,@RolGerencia);

    INSERT dbo.Cliente(nit,razon_social,telefono,correo,activo)
    VALUES('900000001-1',N'Constructora Demostracion Dafel','6010000000',N'demo@example.invalid',1);
    SET @Cliente=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Obra(nombre,direccion,ciudad,indicaciones_acceso)
    VALUES(N'Obra demostracion Dafel',N'Direccion ficticia 123',N'Bogota',N'Ingreso coordinado con porteria.');
    SET @Obra=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Solicitud(id_cliente,id_obra,numero_solicitud,fecha_registro,canal,estado,observaciones)
    VALUES(@Cliente,@Obra,'SOL-DEMO-001','2026-11-16T08:00:00','WEB','CONVERTIDA',N'Solicitud mixta ficticia.');
    SET @Solicitud=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleSolicitud
        (id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
    VALUES(@Solicitud,@RecursoEquipo,1,3,'2026-11-17T08:00:00','2026-11-20T08:00:00');
    SET @DetalleSolicitudEquipo=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleSolicitud
        (id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
    VALUES(@Solicitud,@RecursoPersonal,2,2,'2026-11-17T08:00:00','2026-11-18T08:00:00');
    SET @DetalleSolicitudPersonal=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Cotizacion
        (id_solicitud,id_usuario_autorizador,numero_version,fecha_emision,fecha_vencimiento,
         fecha_autorizacion,estado,fecha_respuesta,motivo_rechazo)
    VALUES(@Solicitud,@UsuarioAdmin,1,'2026-11-16T09:00:00','2026-11-17T09:00:00',
           '2026-11-16T09:15:00','BORRADOR','2026-11-16T09:30:00',NULL);
    SET @Cotizacion=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleCotizacion
        (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
         fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
    VALUES(@Cotizacion,@DetalleSolicitudEquipo,@UnidadEquipo,1,3,
           '2026-11-17T08:00:00','2026-11-20T08:00:00',70000,1);
    SET @DetalleCotizacionEquipo=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleCotizacion
        (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
         fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
    VALUES(@Cotizacion,@DetalleSolicitudPersonal,@UnidadPersonal,2,2,
           '2026-11-17T08:00:00','2026-11-18T08:00:00',100000,1);
    SET @DetalleCotizacionPersonal=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.ConceptoCotizacion
        (id_cotizacion,concepto,descripcion,cantidad,valor_unitario,tipo_concepto)
    VALUES(@Cotizacion,N'Transporte',N'Transporte ficticio de ida.',1,30000,'TRANSPORTE');

    UPDATE dbo.Cotizacion SET estado='ACEPTADA' WHERE id_cotizacion=@Cotizacion;

    INSERT dbo.Alquiler
        (id_cotizacion_aceptada,id_usuario_aprobador,numero_alquiler,fecha_confirmacion,
         estado_operativo,fecha_limite_pago,porcentaje_anticipo_requerido)
    VALUES(@Cotizacion,@UsuarioAdmin,'ALQ-DEMO-001','2026-11-16T09:45:00',
           'EN_PREPARACION','2026-11-17T07:00:00',100);
    SET @Alquiler=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
    VALUES(@Alquiler,@DetalleCotizacionEquipo);
    SET @DetalleAlquilerEquipo=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
    VALUES(@Alquiler,@DetalleCotizacionPersonal);

    INSERT dbo.Pago
        (id_alquiler,id_usuario_registro,fecha_pago,importe,medio_pago,
         referencia_transaccion,estado,tipo_pago)
    VALUES(@Alquiler,@UsuarioAdmin,'2026-11-16T10:00:00',440000,'TRANSFERENCIA',
           N'DEMO-PAGO-001','VIGENTE','ANTICIPO');

    INSERT dbo.AjusteEconomicoAlquiler
        (id_alquiler,id_usuario_autorizador,tipo_ajuste,importe,motivo,fecha_autorizacion,estado)
    VALUES(@Alquiler,@UsuarioAdmin,'INCREMENTO',20000,N'Ampliacion autorizada ficticia.',
           '2026-11-18T12:00:00','VIGENTE');

    INSERT dbo.IncidenciaAlquiler
        (id_detalle_alquiler,id_usuario_registro,tipo,cantidad_afectada,fecha_registro,
         descripcion,estado,resolucion,fecha_resolucion,costo_estimado,
         responsabilidad_acordada,fecha_evaluacion)
    VALUES(@DetalleAlquilerEquipo,@UsuarioAdmin,'DANO',1,'2026-11-19T11:00:00',
           N'Dano ficticio para validar la liquidacion.','AUTORIZADA',
           N'Cargo acordado por debajo de la estimacion.','2026-11-19T12:00:00',
           35000,N'CLIENTE','2026-11-19T11:30:00');
    SET @Incidencia=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.CargoAlquiler
        (id_alquiler,id_usuario_autorizador,concepto,importe,fecha_autorizacion,
         justificacion,estado,tipo_cargo)
    VALUES(@Alquiler,@UsuarioAdmin,N'Dano autorizado',30000,'2026-11-19T12:00:00',
           N'Valor acordado con el cliente.','VIGENTE','DANO');
    SET @Cargo=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.CargoIncidencia(id_cargo,id_incidencia) VALUES(@Cargo,@Incidencia);

    INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
    VALUES(@TipoInicial,@UsuarioAdmin,'2026-11-16T10:15:00',N'Saldo inicial ficticio.');
    SET @MovimientoInicial=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DetalleMovimientoInventario
        (id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
    VALUES(@MovimientoInicial,@RecursoEquipo,@Bodega,@CondicionApto,10);

    COMMIT TRANSACTION;

    SELECT @Alquiler AS id_alquiler,@DetalleAlquilerEquipo AS id_detalle_alquiler_equipo,
           @Bodega AS id_bodega,@UsuarioAdmin AS id_usuario,@EmpleadoOperario AS id_empleado_operario;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
