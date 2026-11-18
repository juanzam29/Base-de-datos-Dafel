USE [DafelDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/*
    Datos ficticios para visualizacion academica en Power BI.
    - Conserva exactamente ocho empleados en el escenario instalado.
    - Daniel Palacios y Patricia mantienen los nombres indicados por la empresa.
    - Los demas nombres y todos los datos comerciales son ficticios.
    - Los codigos DAFEL-BI-* permiten identificar la carga.
*/

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @UsuarioAdmin INT =
    (
        SELECT TOP (1) u.id_usuario
        FROM dbo.Usuario u
        JOIN dbo.Empleado e ON e.id_empleado=u.id_empleado
        ORDER BY CASE WHEN e.numero_documento='1000000001' THEN 0 ELSE 1 END,u.id_usuario
    );

    IF @UsuarioAdmin IS NULL
        THROW 56000,'No existe un usuario de aplicacion para registrar la carga BI.',1;

    EXEC sys.sp_set_session_context @key=N'id_usuario',@value=@UsuarioAdmin;

    /* Normalizacion de los dos empleados creados por la prueba original. */
    UPDATE dbo.Empleado
       SET nombre=N'Daniel Palacios',telefono='3000000001'
     WHERE tipo_documento='CC' AND numero_documento='1000000001';

    UPDATE dbo.Usuario
       SET nombre_usuario=N'daniel.palacios'
     WHERE id_empleado=(SELECT id_empleado FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000001');

    UPDATE dbo.Empleado
       SET nombre=N'Carlos Ramirez',telefono='3000000002'
     WHERE tipo_documento='CC' AND numero_documento='1000000002';

    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000003')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000003',N'Patricia','3000000003',1);
    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000004')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000004',N'Andres Gomez','3000000004',1);
    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000005')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000005',N'Laura Martinez','3000000005',1);
    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000006')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000006',N'Miguel Torres','3000000006',1);
    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000007')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000007',N'Camila Rodriguez','3000000007',1);
    IF NOT EXISTS(SELECT 1 FROM dbo.Empleado WHERE tipo_documento='CC' AND numero_documento='1000000008')
        INSERT dbo.Empleado(tipo_documento,numero_documento,nombre,telefono,activo)
        VALUES('CC','1000000008',N'Jorge Hernandez','3000000008',1);

    IF EXISTS(SELECT 1 FROM dbo.Recurso WHERE codigo='DAFEL-BI-AND-TUB')
    BEGIN
        COMMIT TRANSACTION;
        PRINT N'La carga DAFEL-BI ya existia. Solo se verificaron los empleados.';
        RETURN;
    END;

    DECLARE
        @CategoriaAndamios INT,
        @CategoriaMaquinaria INT,
        @CategoriaPersonal INT,
        @UnidadEquipo INT,
        @UnidadPersonal INT,
        @BodegaPrincipal INT,
        @BodegaNorte INT,
        @CondicionApto INT,
        @CondicionPendiente INT,
        @CondicionDanado INT,
        @TipoInicial INT,
        @TipoDespacho INT,
        @TipoDevolucion INT,
        @TipoInspeccion INT;

    SELECT @CategoriaAndamios=id_categoria FROM dbo.Categoria WHERE nombre=N'Equipos Dafel';
    SELECT @CategoriaPersonal=id_categoria FROM dbo.Categoria WHERE nombre=N'Personal Dafel';

    IF @CategoriaAndamios IS NULL
    BEGIN
        INSERT dbo.Categoria(nombre,descripcion,activo)
        VALUES(N'Equipos Dafel',N'Equipos para alquiler.',1);
        SET @CategoriaAndamios=CONVERT(INT,SCOPE_IDENTITY());
    END;

    INSERT dbo.Categoria(nombre,descripcion,activo)
    VALUES(N'Maquinaria y herramientas',N'Maquinaria y herramientas para construccion.',1);
    SET @CategoriaMaquinaria=CONVERT(INT,SCOPE_IDENTITY());

    IF @CategoriaPersonal IS NULL
    BEGIN
        INSERT dbo.Categoria(nombre,descripcion,activo)
        VALUES(N'Personal Dafel',N'Servicios de personal.',1);
        SET @CategoriaPersonal=CONVERT(INT,SCOPE_IDENTITY());
    END;

    SELECT @UnidadEquipo=id_unidad_cobro FROM dbo.UnidadCobro WHERE nombre=N'BLOQUE_24_HORAS';
    SELECT @UnidadPersonal=id_unidad_cobro FROM dbo.UnidadCobro WHERE nombre=N'JORNADA';
    SELECT @BodegaPrincipal=id_bodega FROM dbo.Bodega WHERE nombre=N'Bodega principal Dafel';
    SELECT @CondicionApto=id_condicion FROM dbo.CondicionMaterial WHERE nombre=N'APTO';
    SELECT @CondicionPendiente=id_condicion FROM dbo.CondicionMaterial WHERE nombre=N'PENDIENTE_INSPECCION';
    SELECT @CondicionDanado=id_condicion FROM dbo.CondicionMaterial WHERE nombre=N'DANADO';
    SELECT @TipoInicial=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'INICIAL';
    SELECT @TipoDespacho=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'DESPACHO';
    SELECT @TipoDevolucion=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'DEVOLUCION';
    SELECT @TipoInspeccion=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'INSPECCION';

    INSERT dbo.Bodega(nombre,direccion,activo)
    VALUES(N'Bodega norte Dafel',N'Zona industrial norte, Bogota',1);
    SET @BodegaNorte=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.Recurso(id_categoria,codigo,nombre,descripcion,naturaleza,activo)
    VALUES
      (@CategoriaAndamios,'DAFEL-BI-AND-TUB',N'Andamio tubular',N'Andamio tubular modular.','EQUIPO',1),
      (@CategoriaAndamios,'DAFEL-BI-PLAT',N'Plataforma metalica',N'Plataforma para sistemas de andamio.','EQUIPO',1),
      (@CategoriaAndamios,'DAFEL-BI-ESC',N'Escalera extensible',N'Escalera industrial extensible.','EQUIPO',1),
      (@CategoriaMaquinaria,'DAFEL-BI-MEZ',N'Mezcladora de concreto',N'Mezcladora portatil para obra.','EQUIPO',1),
      (@CategoriaMaquinaria,'DAFEL-BI-VIB',N'Vibrador de concreto',N'Vibrador electrico industrial.','EQUIPO',1),
      (@CategoriaMaquinaria,'DAFEL-BI-TAL',N'Taladro industrial',N'Taladro de alto rendimiento.','EQUIPO',1),
      (@CategoriaAndamios,'DAFEL-BI-FOR',N'Formaleta metalica',N'Panel modular de formaleta.','EQUIPO',1),
      (@CategoriaPersonal,'DAFEL-BI-SEG',N'Tecnico de seguridad',N'Acompanamiento de seguridad en obra.','PERSONAL',1),
      (@CategoriaPersonal,'DAFEL-BI-MAE',N'Maestro de obra',N'Coordinacion tecnica de montaje.','PERSONAL',1);

    INSERT dbo.TarifaRecurso(id_recurso,id_unidad_cobro,valor_unitario,vigencia_desde,vigencia_hasta)
    SELECT r.id_recurso,
           CASE WHEN r.naturaleza='EQUIPO' THEN @UnidadEquipo ELSE @UnidadPersonal END,
           CASE r.codigo
             WHEN 'DAFEL-BI-AND-TUB' THEN 55000
             WHEN 'DAFEL-BI-PLAT' THEN 35000
             WHEN 'DAFEL-BI-ESC' THEN 28000
             WHEN 'DAFEL-BI-MEZ' THEN 95000
             WHEN 'DAFEL-BI-VIB' THEN 60000
             WHEN 'DAFEL-BI-TAL' THEN 45000
             WHEN 'DAFEL-BI-FOR' THEN 80000
             WHEN 'DAFEL-BI-SEG' THEN 130000
             WHEN 'DAFEL-BI-MAE' THEN 160000
           END,
           '2025-01-01',NULL
    FROM dbo.Recurso r
    WHERE r.codigo LIKE 'DAFEL-BI-%';

    DECLARE @RecursoOperario INT=(SELECT id_recurso FROM dbo.Recurso WHERE codigo='DAFEL-DEMO-OP');
    DECLARE @RecursoSeguridad INT=(SELECT id_recurso FROM dbo.Recurso WHERE codigo='DAFEL-BI-SEG');
    DECLARE @RecursoMaestro INT=(SELECT id_recurso FROM dbo.Recurso WHERE codigo='DAFEL-BI-MAE');

    INSERT dbo.EmpleadoServicio(id_empleado,id_recurso)
    SELECT e.id_empleado,x.id_recurso
    FROM dbo.Empleado e
    CROSS APPLY
    (
        SELECT @RecursoOperario id_recurso WHERE e.numero_documento IN('1000000002','1000000004','1000000006','1000000008')
        UNION ALL SELECT @RecursoSeguridad WHERE e.numero_documento IN('1000000005','1000000007')
        UNION ALL SELECT @RecursoMaestro WHERE e.numero_documento IN('1000000006','1000000008')
    ) x
    WHERE x.id_recurso IS NOT NULL
      AND NOT EXISTS
          (SELECT 1 FROM dbo.EmpleadoServicio es WHERE es.id_empleado=e.id_empleado AND es.id_recurso=x.id_recurso);

    INSERT dbo.Cliente(nit,razon_social,telefono,correo,fecha_registro,activo)
    VALUES
      ('901100001-1',N'Constructora Andina SAS','6014101001',N'contacto@andina.example','2025-01-10',1),
      ('901100002-2',N'Infraestructura Capital SAS','6014101002',N'compras@capital.example','2025-01-15',1),
      ('901100003-3',N'Obras del Centro Ltda','6014101003',N'proyectos@centro.example','2025-02-01',1),
      ('901100004-4',N'Edificaciones Horizonte SAS','6014101004',N'obra@horizonte.example','2025-02-20',1),
      ('901100005-5',N'Ingenieria Urbana Colombia','6014101005',N'logistica@urbana.example','2025-03-05',1),
      ('901100006-6',N'Proyectos Nova SAS','6014101006',N'cotizaciones@nova.example','2025-03-18',1),
      ('901100007-7',N'Consorcio Vial Norte','6014101007',N'almacen@vialnorte.example','2025-04-01',1),
      ('901100008-8',N'Arquitectura y Concreto SAS','6014101008',N'compras@ayc.example','2025-04-14',1),
      ('901100009-9',N'Desarrollos Metropolitanos','6014101009',N'proyectos@metro.example','2025-05-02',1),
      ('901100010-0',N'Construcciones El Dorado','6014101010',N'contacto@eldorado.example','2025-05-21',1),
      ('901100011-1',N'Soluciones Civiles Integradas','6014101011',N'operaciones@sci.example','2025-06-10',1);

    INSERT dbo.Obra(nombre,direccion,ciudad,indicaciones_acceso)
    VALUES
      (N'Torre Andina',N'Carrera 7 # 120-30',N'Bogota',N'Ingreso por porteria de carga.'),
      (N'Centro Empresarial Capital',N'Calle 93 # 15-40',N'Bogota',N'Coordinar ingreso con seguridad.'),
      (N'Renovacion Plaza Central',N'Carrera 13 # 45-20',N'Bogota',N'Acceso por calle lateral.'),
      (N'Conjunto Horizonte',N'Calle 170 # 54-10',N'Bogota',N'Zona de descargue en sotano.'),
      (N'Parque Urbano Sur',N'Avenida Villavicencio # 70-15',N'Bogota',N'Ingreso de maquinaria de 6 a 9 a.m.'),
      (N'Bodegas Nova',N'Autopista Medellin km 4',N'Cota',N'Presentar orden de servicio.'),
      (N'Intercambiador Norte',N'Autopista Norte km 18',N'Chia',N'Acceso por campamento principal.'),
      (N'Complejo Residencial AC',N'Calle 80 # 110-25',N'Bogota',N'Coordinar torre y plataforma.'),
      (N'Estacion Metropolitana',N'Avenida Caracas # 26-10',N'Bogota',N'Acceso nocturno autorizado.'),
      (N'Proyecto El Dorado',N'Avenida El Dorado # 98-50',N'Bogota',N'Ingreso por puerta occidental.'),
      (N'Clinica Integrada',N'Carrera 30 # 64-80',N'Bogota',N'No bloquear acceso de ambulancias.');

    /* Saldo amplio, pero finito, para que las reservas y faltantes sean visibles. */
    DECLARE @MovimientoInicial INT;
    INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
    VALUES(@TipoInicial,@UsuarioAdmin,'2025-01-01',N'Inventario inicial ficticio para analitica Power BI.');
    SET @MovimientoInicial=CONVERT(INT,SCOPE_IDENTITY());

    INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
    SELECT @MovimientoInicial,r.id_recurso,
           CASE WHEN ROW_NUMBER() OVER(ORDER BY r.id_recurso)%2=0 THEN @BodegaNorte ELSE @BodegaPrincipal END,
           @CondicionApto,
           CASE r.codigo
             WHEN 'DAFEL-DEMO-AND' THEN 70
             WHEN 'DAFEL-BI-AND-TUB' THEN 90
             WHEN 'DAFEL-BI-PLAT' THEN 120
             WHEN 'DAFEL-BI-ESC' THEN 28
             WHEN 'DAFEL-BI-MEZ' THEN 18
             WHEN 'DAFEL-BI-VIB' THEN 24
             WHEN 'DAFEL-BI-TAL' THEN 32
             WHEN 'DAFEL-BI-FOR' THEN 75
           END
    FROM dbo.Recurso r
    WHERE r.naturaleza='EQUIPO' AND (r.codigo='DAFEL-DEMO-AND' OR r.codigo LIKE 'DAFEL-BI-%');

    DECLARE @Clientes TABLE(rn INT IDENTITY(1,1),id_cliente INT);
    DECLARE @Obras TABLE(rn INT IDENTITY(1,1),id_obra INT);
    DECLARE @Equipos TABLE(rn INT IDENTITY(1,1),id_recurso INT,id_unidad INT,tarifa DECIMAL(18,2));
    DECLARE @Personal TABLE(rn INT IDENTITY(1,1),id_recurso INT,id_unidad INT,tarifa DECIMAL(18,2));
    DECLARE @Operarios TABLE(rn INT IDENTITY(1,1),id_empleado INT);

    INSERT @Clientes(id_cliente) SELECT id_cliente FROM dbo.Cliente ORDER BY id_cliente;
    INSERT @Obras(id_obra) SELECT id_obra FROM dbo.Obra ORDER BY id_obra;
    INSERT @Equipos(id_recurso,id_unidad,tarifa)
      SELECT r.id_recurso,t.id_unidad_cobro,t.valor_unitario
      FROM dbo.Recurso r JOIN dbo.TarifaRecurso t ON t.id_recurso=r.id_recurso AND t.vigencia_hasta IS NULL
      WHERE r.naturaleza='EQUIPO' ORDER BY r.id_recurso;
    INSERT @Personal(id_recurso,id_unidad,tarifa)
      SELECT r.id_recurso,t.id_unidad_cobro,t.valor_unitario
      FROM dbo.Recurso r JOIN dbo.TarifaRecurso t ON t.id_recurso=r.id_recurso AND t.vigencia_hasta IS NULL
      WHERE r.naturaleza='PERSONAL' ORDER BY r.id_recurso;
    INSERT @Operarios(id_empleado)
      SELECT DISTINCT e.id_empleado FROM dbo.Empleado e JOIN dbo.EmpleadoServicio s ON s.id_empleado=e.id_empleado ORDER BY e.id_empleado;

    DECLARE
        @NClientes INT=(SELECT COUNT(*) FROM @Clientes),
        @NObras INT=(SELECT COUNT(*) FROM @Obras),
        @NEquipos INT=(SELECT COUNT(*) FROM @Equipos),
        @NPersonal INT=(SELECT COUNT(*) FROM @Personal),
        @NOperarios INT=(SELECT COUNT(*) FROM @Operarios),
        @i INT=1,
        @Ahora DATETIME2(0)='2026-11-16T12:00:00';

    WHILE @i<=120
    BEGIN
        DECLARE
            @Cliente INT,
            @Obra INT,
            @RecursoEquipo INT,
            @UnidadEq INT,
            @TarifaEq DECIMAL(18,2),
            @RecursoPersonal INT,
            @UnidadPer INT,
            @TarifaPer DECIMAL(18,2),
            @Empleado INT,
            @FechaRegistro DATETIME2(0),
            @FechaInicio DATETIME2(0),
            @FechaFin DATETIME2(0),
            @Dias INT,
            @CantidadEq INT,
            @CantidadPer INT,
            @Solicitud INT,
            @DetalleEq INT,
            @DetallePer INT=NULL,
            @Evaluacion INT,
            @Cotizacion INT,
            @DetalleCotEq INT,
            @DetalleCotPer INT=NULL,
            @Alquiler INT,
            @DetalleAlqEq INT,
            @DetalleAlqPer INT=NULL,
            @Reserva INT,
            @Bodega INT,
            @ValorEq DECIMAL(18,2),
            @ValorPer DECIMAL(18,2)=0,
            @ValorConceptos DECIMAL(18,2),
            @TotalInicial DECIMAL(18,2),
            @EstadoAlquiler VARCHAR(25),
            @FechaRetorno DATETIME2(0),
            @Despacho INT,
            @DetalleDespacho INT,
            @Devolucion INT,
            @DetalleDevolucion INT,
            @Inspeccion INT,
            @Movimiento INT,
            @CantidadDanada INT,
            @Incidencia INT,
            @Cargo INT;

        SELECT @Cliente=id_cliente FROM @Clientes WHERE rn=((@i-1)%@NClientes)+1;
        SELECT @Obra=id_obra FROM @Obras WHERE rn=((@i-1)%@NObras)+1;
        SELECT @RecursoEquipo=id_recurso,@UnidadEq=id_unidad,@TarifaEq=tarifa FROM @Equipos WHERE rn=((@i-1)%@NEquipos)+1;
        SELECT @RecursoPersonal=id_recurso,@UnidadPer=id_unidad,@TarifaPer=tarifa FROM @Personal WHERE rn=((@i-1)%@NPersonal)+1;
        SELECT @Empleado=id_empleado FROM @Operarios WHERE rn=((@i-1)%@NOperarios)+1;

        SET @FechaRegistro=DATEADD(DAY,((@i-1)*5)/2,'2025-11-10T09:00:00');
        SET @FechaInicio=DATEADD(DAY,3+(@i%6),@FechaRegistro);
        SET @Dias=2+(@i%6);
        SET @FechaFin=DATEADD(DAY,@Dias,@FechaInicio);
        SET @CantidadEq=1+(@i%5);
        SET @CantidadPer=1+(@i%2);
        SET @Bodega=CASE WHEN @i%2=0 THEN @BodegaNorte ELSE @BodegaPrincipal END;

        INSERT dbo.Solicitud(id_cliente,id_obra,numero_solicitud,fecha_registro,canal,estado,observaciones)
        VALUES(@Cliente,@Obra,CONCAT('SOL-BI-',RIGHT(CONCAT('0000',@i),4)),@FechaRegistro,
               CASE WHEN @i%3=0 THEN 'WHATSAPP' ELSE 'WEB' END,'EN_REVISION',N'Solicitud ficticia para analitica.');
        SET @Solicitud=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.DetalleSolicitud(id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
        VALUES(@Solicitud,@RecursoEquipo,1,@CantidadEq,@FechaInicio,@FechaFin);
        SET @DetalleEq=CONVERT(INT,SCOPE_IDENTITY());

        IF @i%3=0
        BEGIN
            INSERT dbo.DetalleSolicitud(id_solicitud,id_recurso,numero_linea,cantidad,fecha_inicio_solicitada,fecha_fin_solicitada)
            VALUES(@Solicitud,@RecursoPersonal,2,@CantidadPer,@FechaInicio,@FechaFin);
            SET @DetallePer=CONVERT(INT,SCOPE_IDENTITY());
        END;

        INSERT dbo.EvaluacionDisponibilidad(id_solicitud,id_usuario_evaluador,fecha_evaluacion)
        VALUES(@Solicitud,@UsuarioAdmin,DATEADD(HOUR,2,@FechaRegistro));
        SET @Evaluacion=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.DetalleEvaluacionDisponibilidad
            (id_evaluacion,id_detalle_solicitud,cantidad_solicitada_evaluada,cantidad_disponible,
             fecha_inicio_evaluada,fecha_fin_evaluada,depende_de_devoluciones,motivo_no_atencion,
             alternativa_propuesta,decision_cliente,fecha_decision_cliente)
        VALUES
            (@Evaluacion,@DetalleEq,@CantidadEq,
             CASE WHEN @i%11=0 THEN CASE WHEN @CantidadEq>1 THEN @CantidadEq-1 ELSE 0 END ELSE @CantidadEq END,
             @FechaInicio,@FechaFin,CASE WHEN @i%11=0 THEN 1 ELSE 0 END,
             CASE WHEN @i%11=0 THEN N'Inventario insuficiente en las fechas solicitadas.' ELSE NULL END,
             CASE WHEN @i%11=0 THEN N'Ajustar cantidad o desplazar la fecha de inicio.' ELSE NULL END,
             CASE WHEN @i%11=0 THEN 'PENDIENTE' ELSE 'ACEPTA' END,
             CASE WHEN @i%11=0 THEN NULL ELSE DATEADD(HOUR,5,@FechaRegistro) END);

        IF @DetallePer IS NOT NULL
        BEGIN
            INSERT dbo.DetalleEvaluacionDisponibilidad
                (id_evaluacion,id_detalle_solicitud,cantidad_solicitada_evaluada,cantidad_disponible,
                 fecha_inicio_evaluada,fecha_fin_evaluada,depende_de_devoluciones,motivo_no_atencion,
                 alternativa_propuesta,decision_cliente,fecha_decision_cliente)
            VALUES(@Evaluacion,@DetallePer,@CantidadPer,@CantidadPer,@FechaInicio,@FechaFin,0,NULL,NULL,'ACEPTA',DATEADD(HOUR,5,@FechaRegistro));
        END;

        /* Cada solicitud numero 11 queda sin cotizar para mostrar demanda no atendida. */
        IF @i%11<>0
        BEGIN
            INSERT dbo.Cotizacion
                (id_solicitud,id_usuario_autorizador,numero_version,fecha_emision,fecha_vencimiento,
                 fecha_autorizacion,estado,fecha_respuesta,motivo_rechazo)
            VALUES(@Solicitud,@UsuarioAdmin,1,DATEADD(HOUR,4,@FechaRegistro),DATEADD(DAY,2,@FechaRegistro),
                   DATEADD(HOUR,5,@FechaRegistro),'BORRADOR',DATEADD(HOUR,8,@FechaRegistro),NULL);
            SET @Cotizacion=CONVERT(INT,SCOPE_IDENTITY());

            INSERT dbo.DetalleCotizacion
                (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
                 fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
            VALUES(@Cotizacion,@DetalleEq,@UnidadEq,1,@CantidadEq,@FechaInicio,@FechaFin,@TarifaEq,@Dias);
            SET @DetalleCotEq=CONVERT(INT,SCOPE_IDENTITY());

            IF @DetallePer IS NOT NULL
            BEGIN
                INSERT dbo.DetalleCotizacion
                    (id_cotizacion,id_detalle_solicitud,id_unidad_cobro,numero_linea,cantidad_ofrecida,
                     fecha_inicio,fecha_fin,tarifa_unitaria,unidades_tiempo_cobrables)
                VALUES(@Cotizacion,@DetallePer,@UnidadPer,2,@CantidadPer,@FechaInicio,@FechaFin,@TarifaPer,@Dias);
                SET @DetalleCotPer=CONVERT(INT,SCOPE_IDENTITY());
            END;

            SET @ValorConceptos=35000+((@i%4)*5000);
            INSERT dbo.ConceptoCotizacion(id_cotizacion,concepto,descripcion,cantidad,valor_unitario,tipo_concepto)
            VALUES(@Cotizacion,N'Transporte',N'Transporte de equipos a la obra.',1,@ValorConceptos,'TRANSPORTE');

            IF @i%4=0
            BEGIN
                INSERT dbo.ConceptoCotizacion(id_cotizacion,concepto,descripcion,cantidad,valor_unitario,tipo_concepto)
                VALUES(@Cotizacion,N'Montaje',N'Montaje tecnico de los elementos.',1,45000,'MONTAJE');
                SET @ValorConceptos+=45000;
            END;

            /* Cada septima cotizacion se rechaza; el resto se convierte en alquiler. */
            IF @i%7=0
            BEGIN
                UPDATE dbo.Cotizacion
                   SET estado='RECHAZADA',motivo_rechazo=CASE WHEN @i%2=0 THEN N'El cliente eligio otra fecha.' ELSE N'Presupuesto no aprobado por el cliente.' END
                 WHERE id_cotizacion=@Cotizacion;
                UPDATE dbo.Solicitud SET estado='RECHAZADA' WHERE id_solicitud=@Solicitud;
            END
            ELSE
            BEGIN
                UPDATE dbo.Cotizacion SET estado='ACEPTADA',motivo_rechazo=NULL WHERE id_cotizacion=@Cotizacion;
                UPDATE dbo.Solicitud SET estado='CONVERTIDA' WHERE id_solicitud=@Solicitud;

                SET @ValorEq=@CantidadEq*@TarifaEq*@Dias;
                SET @ValorPer=CASE WHEN @DetallePer IS NULL THEN 0 ELSE @CantidadPer*@TarifaPer*@Dias END;
                SET @TotalInicial=@ValorEq+@ValorPer+@ValorConceptos;
                SET @EstadoAlquiler=CASE
                    WHEN @FechaInicio>@Ahora THEN 'CONFIRMADO'
                    WHEN @FechaFin>=@Ahora THEN 'EN_CURSO'
                    ELSE 'CERRADO' END;

                INSERT dbo.Alquiler
                    (id_cotizacion_aceptada,id_usuario_aprobador,numero_alquiler,fecha_confirmacion,
                     estado_operativo,fecha_cierre_operativo,fecha_cierre_financiero,fecha_limite_pago,
                     porcentaje_anticipo_requerido)
                VALUES(@Cotizacion,@UsuarioAdmin,CONCAT('ALQ-BI-',RIGHT(CONCAT('0000',@i),4)),DATEADD(HOUR,9,@FechaRegistro),
                       @EstadoAlquiler,
                       CASE WHEN @EstadoAlquiler='CERRADO' THEN DATEADD(DAY,1,@FechaFin) ELSE NULL END,
                       CASE WHEN @EstadoAlquiler='CERRADO' AND @i%10<>0 THEN DATEADD(DAY,2,@FechaFin) ELSE NULL END,
                       DATEADD(HOUR,-2,@FechaInicio),100);
                SET @Alquiler=CONVERT(INT,SCOPE_IDENTITY());

                INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
                VALUES(@Alquiler,@DetalleCotEq);
                SET @DetalleAlqEq=CONVERT(INT,SCOPE_IDENTITY());

                IF @DetalleCotPer IS NOT NULL
                BEGIN
                    INSERT dbo.DetalleAlquiler(id_alquiler,id_detalle_cotizacion)
                    VALUES(@Alquiler,@DetalleCotPer);
                    SET @DetalleAlqPer=CONVERT(INT,SCOPE_IDENTITY());

                    INSERT dbo.AsignacionPersonal
                        (id_detalle_alquiler,id_empleado,id_usuario_registro,fecha_inicio,fecha_fin,estado)
                    VALUES(@DetalleAlqPer,@Empleado,@UsuarioAdmin,@FechaInicio,@FechaFin,
                           CASE WHEN @EstadoAlquiler='CERRADO' THEN 'FINALIZADA' WHEN @EstadoAlquiler='EN_CURSO' THEN 'EN_CURSO' ELSE 'PROGRAMADA' END);
                END;

                INSERT dbo.ReservaEquipo(id_detalle_alquiler,id_bodega,fecha_creacion)
                VALUES(@DetalleAlqEq,@Bodega,DATEADD(HOUR,9,@FechaRegistro));
                SET @Reserva=CONVERT(INT,SCOPE_IDENTITY());

                INSERT dbo.VersionReservaEquipo
                    (id_reserva,numero_version,cantidad_comprometida,fecha_inicio,fecha_fin,fecha_aplicacion,estado)
                VALUES(@Reserva,1,@CantidadEq,@FechaInicio,@FechaFin,DATEADD(HOUR,9,@FechaRegistro),
                       CASE WHEN @EstadoAlquiler='CERRADO' THEN 'CERRADA' ELSE 'ACTIVA' END);

                /* Anticipo y saldo. Los despachos historicos quedan totalmente pagados. */
                INSERT dbo.Pago
                    (id_alquiler,id_usuario_registro,fecha_pago,importe,medio_pago,referencia_transaccion,estado,tipo_pago)
                VALUES(@Alquiler,@UsuarioAdmin,DATEADD(HOUR,10,@FechaRegistro),
                       CASE WHEN @EstadoAlquiler='CONFIRMADO' THEN ROUND(@TotalInicial*.5,0) ELSE ROUND(@TotalInicial*.6,0) END,
                       CASE WHEN @i%2=0 THEN 'TRANSFERENCIA' ELSE 'PSE' END,
                       CONCAT('BI-ANT-',RIGHT(CONCAT('0000',@i),4)),'VIGENTE','ANTICIPO');

                IF @EstadoAlquiler<>'CONFIRMADO'
                BEGIN
                    INSERT dbo.Pago
                        (id_alquiler,id_usuario_registro,fecha_pago,importe,medio_pago,referencia_transaccion,estado,tipo_pago)
                    VALUES(@Alquiler,@UsuarioAdmin,DATEADD(DAY,1,@FechaInicio),@TotalInicial-ROUND(@TotalInicial*.6,0),
                           CASE WHEN @i%3=0 THEN 'EFECTIVO' ELSE 'TRANSFERENCIA' END,
                           CONCAT('BI-SAL-',RIGHT(CONCAT('0000',@i),4)),'VIGENTE','SALDO');
                END;

                /* Ajustes posteriores generan saldos reales sin incumplir el anticipo de despacho. */
                IF @i%10=0
                    INSERT dbo.AjusteEconomicoAlquiler
                        (id_alquiler,id_usuario_autorizador,tipo_ajuste,importe,motivo,fecha_autorizacion,estado)
                    VALUES(@Alquiler,@UsuarioAdmin,'INCREMENTO',50000,N'Ampliacion de plazo autorizada.',DATEADD(DAY,1,@FechaInicio),'VIGENTE');
                ELSE IF @i%13=0
                    INSERT dbo.AjusteEconomicoAlquiler
                        (id_alquiler,id_usuario_autorizador,tipo_ajuste,importe,motivo,fecha_autorizacion,estado)
                    VALUES(@Alquiler,@UsuarioAdmin,'REDUCCION',25000,N'Descuento comercial autorizado.',DATEADD(DAY,1,@FechaInicio),'VIGENTE');

                IF @EstadoAlquiler<>'CONFIRMADO'
                BEGIN
                    INSERT dbo.Despacho(id_alquiler,id_usuario_autorizador,id_empleado_entrega,numero_despacho,fecha_salida,estado)
                    VALUES(@Alquiler,@UsuarioAdmin,@Empleado,CONCAT('DESP-BI-',RIGHT(CONCAT('0000',@i),4)),@FechaInicio,'ENTREGADO');
                    SET @Despacho=CONVERT(INT,SCOPE_IDENTITY());

                    INSERT dbo.DetalleDespacho(id_despacho,id_reserva,cantidad_despachada,observaciones_salida)
                    VALUES(@Despacho,@Reserva,@CantidadEq,N'Despacho ficticio completado.');
                    SET @DetalleDespacho=CONVERT(INT,SCOPE_IDENTITY());

                    INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
                    VALUES(@TipoDespacho,@UsuarioAdmin,@FechaInicio,N'Salida por despacho BI.');
                    SET @Movimiento=CONVERT(INT,SCOPE_IDENTITY());
                    INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
                    VALUES(@Movimiento,@RecursoEquipo,@Bodega,@CondicionApto,-@CantidadEq);
                END;

                IF @EstadoAlquiler='CERRADO'
                BEGIN
                    SET @FechaRetorno=DATEADD(DAY,CASE WHEN @i%5=0 THEN 2 ELSE 0 END,@FechaFin);
                    INSERT dbo.Devolucion(id_alquiler,id_empleado_receptor,id_usuario_registro,numero_devolucion,fecha_recepcion)
                    VALUES(@Alquiler,@Empleado,@UsuarioAdmin,CONCAT('DEV-BI-',RIGHT(CONCAT('0000',@i),4)),@FechaRetorno);
                    SET @Devolucion=CONVERT(INT,SCOPE_IDENTITY());

                    INSERT dbo.DetalleDevolucion(id_devolucion,id_detalle_despacho,id_bodega_recepcion,cantidad_recibida,observaciones)
                    VALUES(@Devolucion,@DetalleDespacho,@Bodega,@CantidadEq,N'Devolucion ficticia recibida.');
                    SET @DetalleDevolucion=CONVERT(INT,SCOPE_IDENTITY());

                    INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
                    VALUES(@TipoDevolucion,@UsuarioAdmin,@FechaRetorno,N'Retorno pendiente de inspeccion BI.');
                    SET @Movimiento=CONVERT(INT,SCOPE_IDENTITY());
                    INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
                    VALUES(@Movimiento,@RecursoEquipo,@Bodega,@CondicionPendiente,@CantidadEq);

                    SET @CantidadDanada=CASE WHEN @i%12=0 THEN 1 ELSE 0 END;
                    INSERT dbo.Inspeccion(id_devolucion,id_empleado_inspector,id_usuario_registro,fecha_inspeccion,observaciones)
                    VALUES(@Devolucion,@Empleado,@UsuarioAdmin,DATEADD(HOUR,6,@FechaRetorno),N'Inspeccion ficticia posterior a la devolucion.');
                    SET @Inspeccion=CONVERT(INT,SCOPE_IDENTITY());

                    IF @CantidadEq-@CantidadDanada>0
                        INSERT dbo.DetalleInspeccion
                            (id_inspeccion,id_detalle_devolucion,id_condicion_resultante,cantidad_revisada,observaciones)
                        VALUES(@Inspeccion,@DetalleDevolucion,@CondicionApto,@CantidadEq-@CantidadDanada,N'Material habilitado.');
                    IF @CantidadDanada>0
                        INSERT dbo.DetalleInspeccion
                            (id_inspeccion,id_detalle_devolucion,id_condicion_resultante,cantidad_revisada,observaciones)
                        VALUES(@Inspeccion,@DetalleDevolucion,@CondicionDanado,@CantidadDanada,N'Material con dano para reparacion.');

                    INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
                    VALUES(@TipoInspeccion,@UsuarioAdmin,DATEADD(HOUR,6,@FechaRetorno),N'Reclasificacion por inspeccion BI.');
                    SET @Movimiento=CONVERT(INT,SCOPE_IDENTITY());
                    INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
                    VALUES(@Movimiento,@RecursoEquipo,@Bodega,@CondicionPendiente,-@CantidadEq);
                    IF @CantidadEq-@CantidadDanada>0
                        INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
                        VALUES(@Movimiento,@RecursoEquipo,@Bodega,@CondicionApto,@CantidadEq-@CantidadDanada);
                    IF @CantidadDanada>0
                        INSERT dbo.DetalleMovimientoInventario(id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
                        VALUES(@Movimiento,@RecursoEquipo,@Bodega,@CondicionDanado,@CantidadDanada);

                    IF @CantidadDanada>0
                    BEGIN
                        INSERT dbo.IncidenciaAlquiler
                            (id_detalle_alquiler,id_usuario_registro,tipo,cantidad_afectada,fecha_registro,
                             descripcion,estado,resolucion,fecha_resolucion,costo_estimado,
                             responsabilidad_acordada,fecha_evaluacion)
                        VALUES(@DetalleAlqEq,@UsuarioAdmin,'DANO',@CantidadDanada,DATEADD(HOUR,7,@FechaRetorno),
                               N'Dano detectado durante la inspeccion ficticia.','AUTORIZADA',
                               N'Cargo acordado con el cliente.',DATEADD(HOUR,9,@FechaRetorno),65000,
                               N'CLIENTE',DATEADD(HOUR,8,@FechaRetorno));
                        SET @Incidencia=CONVERT(INT,SCOPE_IDENTITY());

                        INSERT dbo.CargoAlquiler
                            (id_alquiler,id_usuario_autorizador,concepto,importe,fecha_autorizacion,
                             justificacion,estado,tipo_cargo)
                        VALUES(@Alquiler,@UsuarioAdmin,N'Dano de material',50000,DATEADD(HOUR,9,@FechaRetorno),
                               N'Valor autorizado despues de la inspeccion.','VIGENTE','DANO');
                        SET @Cargo=CONVERT(INT,SCOPE_IDENTITY());
                        INSERT dbo.CargoIncidencia(id_cargo,id_incidencia) VALUES(@Cargo,@Incidencia);
                    END
                    ELSE IF @i%9=0
                    BEGIN
                        INSERT dbo.IncidenciaAlquiler
                            (id_detalle_alquiler,id_usuario_registro,tipo,cantidad_afectada,fecha_registro,
                             descripcion,estado,resolucion,fecha_resolucion,costo_estimado,
                             responsabilidad_acordada,fecha_evaluacion)
                        VALUES(@DetalleAlqEq,@UsuarioAdmin,'RETRASO',1,@FechaRetorno,
                               N'Devolucion posterior a la fecha acordada.','RESUELTA',
                               N'Retraso conciliado con el cliente.',DATEADD(HOUR,2,@FechaRetorno),30000,
                               N'CLIENTE',DATEADD(HOUR,1,@FechaRetorno));
                        SET @Incidencia=CONVERT(INT,SCOPE_IDENTITY());

                        INSERT dbo.CargoAlquiler
                            (id_alquiler,id_usuario_autorizador,concepto,importe,fecha_autorizacion,
                             justificacion,estado,tipo_cargo)
                        VALUES(@Alquiler,@UsuarioAdmin,N'Retraso en devolucion',30000,DATEADD(HOUR,2,@FechaRetorno),
                               N'Cargo autorizado por retraso.','VIGENTE','RETRASO');
                        SET @Cargo=CONVERT(INT,SCOPE_IDENTITY());
                        INSERT dbo.CargoIncidencia(id_cargo,id_incidencia) VALUES(@Cargo,@Incidencia);
                    END;
                END;
            END;
        END;

        SET @i+=1;
    END;

    COMMIT TRANSACTION;

    SELECT COUNT(*) empleados FROM dbo.Empleado;
    SELECT COUNT(*) solicitudes_bi FROM dbo.Solicitud WHERE numero_solicitud LIKE 'SOL-BI-%';
    SELECT COUNT(*) alquileres_bi FROM dbo.Alquiler WHERE numero_alquiler LIKE 'ALQ-BI-%';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
