USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE OR ALTER TRIGGER dbo.TR_DetalleDespacho_Limite
ON dbo.DetalleDespacho
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM (SELECT DISTINCT id_reserva FROM inserted) i
        CROSS APPLY
        (
            SELECT SUM(CONVERT(BIGINT,cantidad_despachada)) AS total
            FROM dbo.DetalleDespacho
            WHERE id_reserva=i.id_reserva
        ) d
        CROSS APPLY
        (
            SELECT TOP(1) cantidad_comprometida
            FROM dbo.VersionReservaEquipo
            WHERE id_reserva=i.id_reserva AND estado='ACTIVA'
            ORDER BY numero_version DESC
        ) v
        WHERE d.total>v.cantidad_comprometida
    )
        THROW 55101,'La cantidad despachada supera la reserva activa.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_DetalleDevolucion_Limite
ON dbo.DetalleDevolucion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM (SELECT DISTINCT id_detalle_despacho FROM inserted) i
        JOIN dbo.DetalleDespacho dd ON dd.id_detalle_despacho=i.id_detalle_despacho
        CROSS APPLY
        (
            SELECT SUM(CONVERT(BIGINT,cantidad_recibida)) AS total
            FROM dbo.DetalleDevolucion
            WHERE id_detalle_despacho=i.id_detalle_despacho
        ) d
        WHERE d.total>dd.cantidad_despachada
    )
        THROW 55102,'La cantidad devuelta supera la cantidad despachada.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_DetalleInspeccion_Limite
ON dbo.DetalleInspeccion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM (SELECT DISTINCT id_detalle_devolucion FROM inserted) i
        JOIN dbo.DetalleDevolucion dd ON dd.id_detalle_devolucion=i.id_detalle_devolucion
        CROSS APPLY
        (
            SELECT SUM(CONVERT(BIGINT,cantidad_revisada)) AS total
            FROM dbo.DetalleInspeccion
            WHERE id_detalle_devolucion=i.id_detalle_devolucion
        ) d
        WHERE d.total>dd.cantidad_recibida
    )
        THROW 55103,'La cantidad inspeccionada supera la cantidad recibida.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_AsignacionPersonal_Cruces
ON dbo.AsignacionPersonal
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN dbo.AsignacionPersonal a
          ON a.id_empleado=i.id_empleado
         AND a.id_asignacion<>i.id_asignacion
         AND a.estado NOT IN ('CANCELADA','REEMPLAZADA')
         AND i.estado NOT IN ('CANCELADA','REEMPLAZADA')
         AND a.fecha_inicio<i.fecha_fin
         AND a.fecha_fin>i.fecha_inicio
    )
        THROW 55104,'El empleado tiene otra asignacion superpuesta.',1;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN dbo.IndisponibilidadPersonal p
          ON p.id_empleado=i.id_empleado
         AND p.fecha_inicio<i.fecha_fin
         AND p.fecha_fin>i.fecha_inicio
        WHERE i.estado NOT IN ('CANCELADA','REEMPLAZADA')
    )
        THROW 55105,'El empleado esta indisponible durante la asignacion.',1;

    IF EXISTS
    (
        SELECT 1
        FROM (SELECT DISTINCT id_detalle_alquiler FROM inserted) i
        JOIN dbo.v_CondicionVigenteAlquiler ca
          ON ca.id_detalle_alquiler=i.id_detalle_alquiler
        CROSS APPLY
        (
            SELECT COUNT_BIG(*) cantidad_asignada
            FROM dbo.AsignacionPersonal a
            WHERE a.id_detalle_alquiler=i.id_detalle_alquiler
              AND a.estado NOT IN ('CANCELADA','REEMPLAZADA')
        ) x
        WHERE x.cantidad_asignada>ca.cantidad
    )
        THROW 55109,'Las asignaciones activas superan la cantidad contratada.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Reembolso_Limite
ON dbo.Reembolso
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM (SELECT DISTINCT id_alquiler FROM inserted) i
        OUTER APPLY
        (
            SELECT SUM(CONVERT(DECIMAL(18,2),importe)) AS pagos
            FROM dbo.Pago
            WHERE id_alquiler=i.id_alquiler AND estado='VIGENTE'
        ) p
        OUTER APPLY
        (
            SELECT SUM(CONVERT(DECIMAL(18,2),importe)) AS reembolsos
            FROM dbo.Reembolso
            WHERE id_alquiler=i.id_alquiler AND estado IN ('AUTORIZADO','EFECTUADO')
        ) r
        WHERE COALESCE(r.reembolsos,0)>COALESCE(p.pagos,0)
    )
        THROW 55106,'Los reembolsos autorizados superan los pagos vigentes.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Alquiler_Transicion
ON dbo.Alquiler
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.id_alquiler=i.id_alquiler
        WHERE i.estado_operativo<>d.estado_operativo
          AND NOT
          (
              (d.estado_operativo='CONFIRMADO' AND i.estado_operativo IN ('EN_PREPARACION','CANCELADO')) OR
              (d.estado_operativo='EN_PREPARACION' AND i.estado_operativo IN ('EN_CURSO','CANCELADO')) OR
              (d.estado_operativo='EN_CURSO' AND i.estado_operativo IN ('PENDIENTE_DEVOLUCION','CERRADO')) OR
              (d.estado_operativo='PENDIENTE_DEVOLUCION' AND i.estado_operativo='CERRADO')
          )
    )
        THROW 55107,'Transicion de estado del alquiler no permitida.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Despacho_Transicion
ON dbo.Despacho
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.id_despacho=i.id_despacho
        WHERE i.estado<>d.estado
          AND NOT
          (
              (d.estado='PREPARADO' AND i.estado IN ('AUTORIZADO','CANCELADO')) OR
              (d.estado='AUTORIZADO' AND i.estado IN ('EN_TRANSITO','CANCELADO')) OR
              (d.estado='EN_TRANSITO' AND i.estado='ENTREGADO')
          )
    )
        THROW 55108,'Transicion de estado del despacho no permitida.',1;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_CrearReservaEquipo
    @IdDetalleAlquiler INT,
    @IdBodega INT,
    @Cantidad INT,
    @FechaInicio DATETIME2(0),
    @FechaFin DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad<=0 OR @FechaInicio IS NULL OR @FechaFin IS NULL OR @FechaFin<=@FechaInicio
        THROW 55200,'Cantidad o periodo de reserva invalido.',1;

    DECLARE @IdRecurso INT,@Naturaleza VARCHAR(10),@Stock BIGINT,@Pico BIGINT=0,
            @ResultadoBloqueo INT,@IdReserva INT,@RecursoBloqueo NVARCHAR(255);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @IdRecurso=ca.id_recurso,@Naturaleza=r.naturaleza
        FROM dbo.v_CondicionVigenteAlquiler ca
        JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
        JOIN dbo.Alquiler a ON a.id_alquiler=ca.id_alquiler
        WHERE ca.id_detalle_alquiler=@IdDetalleAlquiler
          AND a.estado_operativo NOT IN ('CERRADO','CANCELADO')
          AND @FechaInicio>=ca.fecha_inicio AND @FechaFin<=ca.fecha_fin;

        IF @IdRecurso IS NULL OR @Naturaleza<>'EQUIPO'
            THROW 55201,'El detalle no corresponde a un equipo alquilable.',1;

        SET @RecursoBloqueo=CONCAT('DafelDB_Reserva_',@IdRecurso,'_',@IdBodega);
        EXEC @ResultadoBloqueo=sys.sp_getapplock
            @Resource=@RecursoBloqueo,
            @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=15000;
        IF @ResultadoBloqueo<0 THROW 55202,'No se obtuvo el bloqueo de reserva.',1;

        SELECT @Stock=COALESCE(SUM(s.cantidad),0)
        FROM dbo.v_SaldoFisico s
        JOIN dbo.CondicionMaterial c ON c.id_condicion=s.id_condicion
        WHERE s.id_recurso=@IdRecurso AND s.id_bodega=@IdBodega AND c.permite_despacho=1;

        ;WITH compromisos AS
        (
            SELECT v.fecha_inicio,v.fecha_fin,
                   CASE WHEN v.cantidad_comprometida>COALESCE(d.despachada,0)
                        THEN v.cantidad_comprometida-COALESCE(d.despachada,0) ELSE 0 END cantidad
            FROM dbo.v_ReservaVigente v
            JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=v.id_detalle_alquiler
            OUTER APPLY
            (
                SELECT SUM(CONVERT(BIGINT,cantidad_despachada)) despachada
                FROM dbo.DetalleDespacho WHERE id_reserva=v.id_reserva
            ) d
            WHERE ca.id_recurso=@IdRecurso AND v.id_bodega=@IdBodega
              AND v.estado='ACTIVA' AND v.fecha_inicio<@FechaFin AND v.fecha_fin>@FechaInicio
        ),
        puntos AS
        (
            SELECT @FechaInicio fecha
            UNION
            SELECT fecha_inicio FROM compromisos
            WHERE fecha_inicio>@FechaInicio AND fecha_inicio<@FechaFin
        ),
        cargas AS
        (
            SELECT p.fecha,COALESCE(SUM(c.cantidad),0) cantidad
            FROM puntos p
            LEFT JOIN compromisos c ON c.fecha_inicio<=p.fecha AND c.fecha_fin>p.fecha
            GROUP BY p.fecha
        )
        SELECT @Pico=COALESCE(MAX(cantidad),0) FROM cargas;

        IF @Stock-@Pico<@Cantidad
            THROW 55203,'Disponibilidad insuficiente para reservar el periodo completo.',1;

        INSERT dbo.ReservaEquipo(id_detalle_alquiler,id_bodega,fecha_creacion)
        VALUES(@IdDetalleAlquiler,@IdBodega,SYSDATETIME());
        SET @IdReserva=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.VersionReservaEquipo
            (id_reserva,numero_version,cantidad_comprometida,fecha_inicio,fecha_fin,fecha_aplicacion,estado)
        VALUES(@IdReserva,1,@Cantidad,@FechaInicio,@FechaFin,SYSDATETIME(),'ACTIVA');

        COMMIT TRANSACTION;
        SELECT @IdReserva AS id_reserva,1 AS numero_version,'ACTIVA' AS estado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_AsignarPersonalSeguro
    @IdDetalleAlquiler INT,
    @IdEmpleado INT,
    @IdUsuarioRegistro INT,
    @FechaInicio DATETIME2(0),
    @FechaFin DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @FechaInicio IS NULL OR @FechaFin IS NULL OR @FechaFin<=@FechaInicio
        THROW 55210,'Periodo de asignacion invalido.',1;

    DECLARE @IdRecurso INT,@Naturaleza VARCHAR(10),@ResultadoBloqueo INT,@IdAsignacion INT,
            @RecursoBloqueo NVARCHAR(255);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @IdRecurso=ca.id_recurso,@Naturaleza=r.naturaleza
        FROM dbo.v_CondicionVigenteAlquiler ca
        JOIN dbo.Recurso r ON r.id_recurso=ca.id_recurso
        WHERE ca.id_detalle_alquiler=@IdDetalleAlquiler
          AND @FechaInicio>=ca.fecha_inicio AND @FechaFin<=ca.fecha_fin;

        IF @IdRecurso IS NULL OR @Naturaleza<>'PERSONAL'
            THROW 55211,'El detalle no corresponde a personal o el periodo esta fuera del alquiler.',1;

        IF NOT EXISTS
        (
            SELECT 1 FROM dbo.Empleado e
            JOIN dbo.EmpleadoServicio es ON es.id_empleado=e.id_empleado
            WHERE e.id_empleado=@IdEmpleado AND e.activo=1 AND es.id_recurso=@IdRecurso
        )
            THROW 55212,'El empleado no esta habilitado para este servicio.',1;

        SET @RecursoBloqueo=CONCAT('DafelDB_Empleado_',@IdEmpleado);
        EXEC @ResultadoBloqueo=sys.sp_getapplock
            @Resource=@RecursoBloqueo,
            @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=15000;
        IF @ResultadoBloqueo<0 THROW 55213,'No se obtuvo el bloqueo del empleado.',1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.AsignacionPersonal WITH(UPDLOCK,HOLDLOCK)
            WHERE id_empleado=@IdEmpleado AND estado NOT IN ('CANCELADA','REEMPLAZADA')
              AND fecha_inicio<@FechaFin AND fecha_fin>@FechaInicio
        )
            THROW 55214,'El empleado tiene otra asignacion superpuesta.',1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.IndisponibilidadPersonal WITH(UPDLOCK,HOLDLOCK)
            WHERE id_empleado=@IdEmpleado
              AND fecha_inicio<@FechaFin AND fecha_fin>@FechaInicio
        )
            THROW 55215,'El empleado esta indisponible en el periodo.',1;

        INSERT dbo.AsignacionPersonal
            (id_detalle_alquiler,id_empleado,id_usuario_registro,fecha_inicio,fecha_fin,estado)
        VALUES(@IdDetalleAlquiler,@IdEmpleado,@IdUsuarioRegistro,@FechaInicio,@FechaFin,'PROGRAMADA');
        SET @IdAsignacion=CONVERT(INT,SCOPE_IDENTITY());

        COMMIT TRANSACTION;
        SELECT @IdAsignacion AS id_asignacion,'PROGRAMADA' AS estado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_AutorizarDespacho
    @IdDespacho INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdAlquiler INT,@Porcentaje DECIMAL(5,2),@ValorInicial DECIMAL(18,2),
            @Pagado DECIMAL(18,2),@Requerido DECIMAL(18,2);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @IdAlquiler=d.id_alquiler,@Porcentaje=a.porcentaje_anticipo_requerido
        FROM dbo.Despacho d WITH(UPDLOCK,HOLDLOCK)
        JOIN dbo.Alquiler a ON a.id_alquiler=d.id_alquiler
        WHERE d.id_despacho=@IdDespacho AND d.estado='PREPARADO';

        IF @IdAlquiler IS NULL THROW 55220,'El despacho no existe o no esta preparado.',1;

        SELECT @ValorInicial=
            COALESCE((SELECT SUM(dc.cantidad_ofrecida*dc.tarifa_unitaria*dc.unidades_tiempo_cobrables)
                      FROM dbo.DetalleAlquiler da JOIN dbo.DetalleCotizacion dc ON dc.id_detalle_cotizacion=da.id_detalle_cotizacion
                      WHERE da.id_alquiler=@IdAlquiler),0)
            +COALESCE((SELECT SUM(co.cantidad*co.valor_unitario)
                       FROM dbo.Alquiler a JOIN dbo.ConceptoCotizacion co ON co.id_cotizacion=a.id_cotizacion_aceptada
                       WHERE a.id_alquiler=@IdAlquiler),0);

        SELECT @Pagado=COALESCE(SUM(importe),0)
        FROM dbo.Pago WITH(UPDLOCK,HOLDLOCK)
        WHERE id_alquiler=@IdAlquiler AND estado='VIGENTE';

        SET @Requerido=ROUND(@ValorInicial*@Porcentaje/100.0,2);
        IF @Pagado<@Requerido
            THROW 55221,'El pago vigente no cubre el anticipo requerido.',1;

        UPDATE dbo.Despacho SET estado='AUTORIZADO' WHERE id_despacho=@IdDespacho;
        UPDATE dbo.Alquiler
        SET estado_operativo='EN_CURSO'
        WHERE id_alquiler=@IdAlquiler AND estado_operativo='EN_PREPARACION';
        COMMIT TRANSACTION;
        SELECT @IdDespacho id_despacho,@Requerido anticipo_requerido,@Pagado pagado,'AUTORIZADO' estado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_CancelarAlquilerAntesDespacho
    @IdAlquiler INT,
    @IdUsuarioAutorizador INT,
    @IdUsuarioRegistro INT,
    @Motivo NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NULLIF(LTRIM(RTRIM(@Motivo)),N'') IS NULL
        THROW 55280,'Debe registrar el motivo de cancelacion.',1;

    DECLARE @Pagos DECIMAL(18,2),@Reembolsos DECIMAL(18,2),@ReembolsoNuevo DECIMAL(18,2);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1 FROM dbo.Alquiler WITH(UPDLOCK,HOLDLOCK)
            WHERE id_alquiler=@IdAlquiler AND estado_operativo IN ('CONFIRMADO','EN_PREPARACION')
        )
            THROW 55281,'El alquiler no puede cancelarse por esta operacion.',1;

        IF EXISTS
        (
            SELECT 1 FROM dbo.Despacho d
            JOIN dbo.DetalleDespacho dd ON dd.id_despacho=d.id_despacho
            WHERE d.id_alquiler=@IdAlquiler AND dd.cantidad_despachada>0
        )
            THROW 55282,'Ya existen cantidades despachadas; se requiere liquidacion posterior al retorno.',1;

        ;WITH ultimas AS
        (
            SELECT v.*,
                   ROW_NUMBER() OVER(PARTITION BY v.id_reserva ORDER BY v.numero_version DESC) rn
            FROM dbo.VersionReservaEquipo v
            JOIN dbo.ReservaEquipo r ON r.id_reserva=v.id_reserva
            JOIN dbo.DetalleAlquiler da ON da.id_detalle_alquiler=r.id_detalle_alquiler
            WHERE da.id_alquiler=@IdAlquiler
        )
        INSERT dbo.VersionReservaEquipo
            (id_reserva,numero_version,cantidad_comprometida,fecha_inicio,fecha_fin,fecha_aplicacion,estado)
        SELECT id_reserva,numero_version+1,cantidad_comprometida,fecha_inicio,fecha_fin,SYSDATETIME(),'CANCELADA'
        FROM ultimas WHERE rn=1 AND estado='ACTIVA';

        SELECT @Pagos=COALESCE(SUM(importe),0)
        FROM dbo.Pago WITH(UPDLOCK,HOLDLOCK)
        WHERE id_alquiler=@IdAlquiler AND estado='VIGENTE';
        SELECT @Reembolsos=COALESCE(SUM(importe),0)
        FROM dbo.Reembolso WITH(UPDLOCK,HOLDLOCK)
        WHERE id_alquiler=@IdAlquiler AND estado IN ('AUTORIZADO','EFECTUADO');
        SET @ReembolsoNuevo=@Pagos-@Reembolsos;

        IF @ReembolsoNuevo>0
            INSERT dbo.Reembolso
                (id_alquiler,id_usuario_autorizador,id_usuario_registro,importe,motivo,estado,fecha_autorizacion)
            VALUES(@IdAlquiler,@IdUsuarioAutorizador,@IdUsuarioRegistro,@ReembolsoNuevo,
                   @Motivo,'AUTORIZADO',SYSDATETIME());

        UPDATE dbo.Alquiler
        SET estado_operativo='CANCELADO',fecha_cierre_operativo=SYSDATETIME()
        WHERE id_alquiler=@IdAlquiler;

        COMMIT TRANSACTION;
        SELECT @IdAlquiler id_alquiler,@ReembolsoNuevo reembolso_autorizado,'CANCELADO' estado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_RegistrarDetalleDespacho
    @IdDespacho INT,
    @IdReserva INT,
    @Cantidad INT,
    @Observaciones NVARCHAR(1000)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad<=0 THROW 55230,'Cantidad de despacho invalida.',1;

    DECLARE @IdRecurso INT,@IdBodega INT,@IdUsuario INT,@IdCondicion INT,
            @IdTipo INT,@Stock BIGINT,@IdDetalle INT,@IdMovimiento INT,@Bloqueo INT,
            @RecursoBloqueo NVARCHAR(255);

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @IdRecurso=ca.id_recurso,@IdBodega=re.id_bodega,@IdUsuario=d.id_usuario_autorizador
        FROM dbo.Despacho d WITH(UPDLOCK,HOLDLOCK)
        JOIN dbo.ReservaEquipo re ON re.id_reserva=@IdReserva
        JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
        WHERE d.id_despacho=@IdDespacho AND d.estado IN ('AUTORIZADO','EN_TRANSITO')
          AND ca.id_alquiler=d.id_alquiler;

        IF @IdRecurso IS NULL THROW 55231,'Despacho o reserva incompatible.',1;

        SET @RecursoBloqueo=CONCAT('DafelDB_Inventario_',@IdRecurso,'_',@IdBodega);
        EXEC @Bloqueo=sys.sp_getapplock
            @Resource=@RecursoBloqueo,
            @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=15000;
        IF @Bloqueo<0 THROW 55232,'No se obtuvo el bloqueo de inventario.',1;

        SELECT TOP(1) @IdCondicion=id_condicion
        FROM dbo.CondicionMaterial WHERE permite_despacho=1 ORDER BY id_condicion;
        SELECT @IdTipo=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'DESPACHO';
        IF @IdCondicion IS NULL OR @IdTipo IS NULL
            THROW 55233,'Faltan catalogos para registrar el despacho.',1;

        SELECT @Stock=COALESCE(SUM(cantidad),0)
        FROM dbo.v_SaldoFisico WITH(HOLDLOCK)
        WHERE id_recurso=@IdRecurso AND id_bodega=@IdBodega AND id_condicion=@IdCondicion;
        IF @Stock<@Cantidad THROW 55234,'Stock apto insuficiente para despachar.',1;

        INSERT dbo.DetalleDespacho(id_despacho,id_reserva,cantidad_despachada,observaciones_salida)
        VALUES(@IdDespacho,@IdReserva,@Cantidad,@Observaciones);
        SET @IdDetalle=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
        VALUES(@IdTipo,@IdUsuario,SYSDATETIME(),N'Salida por despacho');
        SET @IdMovimiento=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.DetalleMovimientoInventario
            (id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
        VALUES(@IdMovimiento,@IdRecurso,@IdBodega,@IdCondicion,-@Cantidad);
        INSERT dbo.MovimientoDespacho(id_movimiento,id_detalle_despacho)
        VALUES(@IdMovimiento,@IdDetalle);

        COMMIT TRANSACTION;
        SELECT @IdDetalle id_detalle_despacho,@IdMovimiento id_movimiento;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_RegistrarDetalleDevolucion
    @IdDevolucion INT,
    @IdDetalleDespacho INT,
    @IdBodegaRecepcion INT,
    @Cantidad INT,
    @Observaciones NVARCHAR(1000)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad<=0 THROW 55240,'Cantidad de devolucion invalida.',1;

    DECLARE @IdRecurso INT,@IdUsuario INT,@IdCondicion INT,@IdTipo INT,
            @IdDetalle INT,@IdMovimiento INT,@IdAlquiler INT;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @IdAlquiler=v.id_alquiler,@IdUsuario=v.id_usuario_registro,
               @IdRecurso=ca.id_recurso
        FROM dbo.Devolucion v WITH(UPDLOCK,HOLDLOCK)
        JOIN dbo.DetalleDespacho dd ON dd.id_detalle_despacho=@IdDetalleDespacho
        JOIN dbo.Despacho d ON d.id_despacho=dd.id_despacho AND d.id_alquiler=v.id_alquiler
        JOIN dbo.ReservaEquipo re ON re.id_reserva=dd.id_reserva
        JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
        WHERE v.id_devolucion=@IdDevolucion;

        IF @IdRecurso IS NULL THROW 55241,'La devolucion no corresponde al despacho.',1;

        SELECT TOP(1) @IdCondicion=id_condicion
        FROM dbo.CondicionMaterial
        WHERE permite_despacho=0 AND nombre=N'PENDIENTE_INSPECCION';
        SELECT @IdTipo=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'DEVOLUCION';
        IF @IdCondicion IS NULL OR @IdTipo IS NULL
            THROW 55242,'Faltan catalogos para registrar la devolucion.',1;

        INSERT dbo.DetalleDevolucion
            (id_devolucion,id_detalle_despacho,id_bodega_recepcion,cantidad_recibida,observaciones)
        VALUES(@IdDevolucion,@IdDetalleDespacho,@IdBodegaRecepcion,@Cantidad,@Observaciones);
        SET @IdDetalle=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
        VALUES(@IdTipo,@IdUsuario,SYSDATETIME(),N'Retorno pendiente de inspeccion');
        SET @IdMovimiento=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.DetalleMovimientoInventario
            (id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
        VALUES(@IdMovimiento,@IdRecurso,@IdBodegaRecepcion,@IdCondicion,@Cantidad);
        INSERT dbo.MovimientoDevolucion(id_movimiento,id_detalle_devolucion)
        VALUES(@IdMovimiento,@IdDetalle);

        COMMIT TRANSACTION;
        SELECT @IdDetalle id_detalle_devolucion,@IdMovimiento id_movimiento;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_RegistrarDetalleInspeccion
    @IdInspeccion INT,
    @IdDetalleDevolucion INT,
    @IdCondicionResultado INT,
    @Cantidad INT,
    @Observaciones NVARCHAR(1000)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad<=0 THROW 55250,'Cantidad de inspeccion invalida.',1;

    DECLARE @IdRecurso INT,@IdBodega INT,@IdUsuario INT,@IdPendiente INT,@IdTipo INT,
            @IdDetalle INT,@IdMovimiento INT;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @IdUsuario=i.id_usuario_registro,@IdBodega=dd.id_bodega_recepcion,
               @IdRecurso=ca.id_recurso
        FROM dbo.Inspeccion i WITH(UPDLOCK,HOLDLOCK)
        JOIN dbo.DetalleDevolucion dd ON dd.id_detalle_devolucion=@IdDetalleDevolucion
        JOIN dbo.Devolucion v ON v.id_devolucion=dd.id_devolucion AND v.id_devolucion=i.id_devolucion
        JOIN dbo.DetalleDespacho dp ON dp.id_detalle_despacho=dd.id_detalle_despacho
        JOIN dbo.ReservaEquipo re ON re.id_reserva=dp.id_reserva
        JOIN dbo.v_CondicionVigenteAlquiler ca ON ca.id_detalle_alquiler=re.id_detalle_alquiler
        WHERE i.id_inspeccion=@IdInspeccion;

        IF @IdRecurso IS NULL THROW 55251,'La inspeccion no corresponde a la devolucion.',1;

        SELECT @IdPendiente=id_condicion FROM dbo.CondicionMaterial WHERE nombre=N'PENDIENTE_INSPECCION';
        SELECT @IdTipo=id_tipo_movimiento FROM dbo.TipoMovimiento WHERE nombre=N'INSPECCION';
        IF @IdPendiente IS NULL OR @IdTipo IS NULL OR
           NOT EXISTS(SELECT 1 FROM dbo.CondicionMaterial WHERE id_condicion=@IdCondicionResultado)
            THROW 55252,'Faltan catalogos para registrar la inspeccion.',1;

        INSERT dbo.DetalleInspeccion
            (id_inspeccion,id_detalle_devolucion,id_condicion_resultante,cantidad_revisada,observaciones)
        VALUES(@IdInspeccion,@IdDetalleDevolucion,@IdCondicionResultado,@Cantidad,@Observaciones);
        SET @IdDetalle=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.MovimientoInventario(id_tipo_movimiento,id_usuario_registro,fecha_movimiento,motivo)
        VALUES(@IdTipo,@IdUsuario,SYSDATETIME(),N'Reclasificacion por inspeccion');
        SET @IdMovimiento=CONVERT(INT,SCOPE_IDENTITY());

        INSERT dbo.DetalleMovimientoInventario
            (id_movimiento,id_recurso,id_bodega,id_condicion,cantidad_variacion)
        VALUES
            (@IdMovimiento,@IdRecurso,@IdBodega,@IdPendiente,-@Cantidad),
            (@IdMovimiento,@IdRecurso,@IdBodega,@IdCondicionResultado,@Cantidad);
        INSERT dbo.MovimientoInspeccion(id_movimiento,id_detalle_inspeccion)
        VALUES(@IdMovimiento,@IdDetalle);

        COMMIT TRANSACTION;
        SELECT @IdDetalle id_detalle_inspeccion,@IdMovimiento id_movimiento;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_AutorizarReembolso
    @IdAlquiler INT,
    @IdUsuarioAutorizador INT,
    @IdUsuarioRegistro INT,
    @Importe DECIMAL(18,2),
    @Motivo NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Importe<=0 OR NULLIF(LTRIM(RTRIM(@Motivo)),N'') IS NULL
        THROW 55260,'Importe o motivo de reembolso invalido.',1;

    DECLARE @Pagos DECIMAL(18,2),@Comprometido DECIMAL(18,2),@IdReembolso INT;

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;

        SELECT @Pagos=COALESCE(SUM(importe),0)
        FROM dbo.Pago WITH(UPDLOCK,HOLDLOCK)
        WHERE id_alquiler=@IdAlquiler AND estado='VIGENTE';
        SELECT @Comprometido=COALESCE(SUM(importe),0)
        FROM dbo.Reembolso WITH(UPDLOCK,HOLDLOCK)
        WHERE id_alquiler=@IdAlquiler AND estado IN ('AUTORIZADO','EFECTUADO');

        IF @Comprometido+@Importe>@Pagos
            THROW 55261,'El reembolso supera los pagos disponibles.',1;

        INSERT dbo.Reembolso
            (id_alquiler,id_usuario_autorizador,id_usuario_registro,importe,motivo,estado,fecha_autorizacion)
        VALUES(@IdAlquiler,@IdUsuarioAutorizador,@IdUsuarioRegistro,@Importe,@Motivo,'AUTORIZADO',SYSDATETIME());
        SET @IdReembolso=CONVERT(INT,SCOPE_IDENTITY());

        COMMIT TRANSACTION;
        SELECT @IdReembolso id_reembolso,'AUTORIZADO' estado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE operacion.usp_CerrarAlquiler
    @IdAlquiler INT,
    @TipoCierre VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @TipoCierre NOT IN ('OPERATIVO','FINANCIERO')
        THROW 55270,'Tipo de cierre invalido.',1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS(SELECT 1 FROM dbo.Alquiler WITH(UPDLOCK,HOLDLOCK) WHERE id_alquiler=@IdAlquiler)
            THROW 55271,'Alquiler inexistente.',1;

        IF @TipoCierre='OPERATIVO'
        BEGIN
            IF EXISTS
            (
                SELECT 1
                FROM dbo.DetalleDespacho dd
                JOIN dbo.Despacho d ON d.id_despacho=dd.id_despacho
                OUTER APPLY
                (
                    SELECT SUM(CONVERT(BIGINT,cantidad_recibida)) devuelta
                    FROM dbo.DetalleDevolucion WHERE id_detalle_despacho=dd.id_detalle_despacho
                ) x
                WHERE d.id_alquiler=@IdAlquiler
                  AND dd.cantidad_despachada<>COALESCE(x.devuelta,0)
            )
                THROW 55272,'Hay cantidades despachadas pendientes de devolucion.',1;

            IF EXISTS
            (
                SELECT 1
                FROM dbo.DetalleDevolucion dd
                JOIN dbo.Devolucion d ON d.id_devolucion=dd.id_devolucion
                OUTER APPLY
                (
                    SELECT SUM(CONVERT(BIGINT,cantidad_revisada)) revisada
                    FROM dbo.DetalleInspeccion WHERE id_detalle_devolucion=dd.id_detalle_devolucion
                ) x
                WHERE d.id_alquiler=@IdAlquiler
                  AND dd.cantidad_recibida<>COALESCE(x.revisada,0)
            )
                THROW 55273,'Hay cantidades devueltas pendientes de inspeccion.',1;

            UPDATE dbo.Alquiler
            SET estado_operativo='CERRADO',fecha_cierre_operativo=SYSDATETIME()
            WHERE id_alquiler=@IdAlquiler;
        END
        ELSE
        BEGIN
            IF EXISTS
            (
                SELECT 1 FROM dbo.v_Liquidacion
                WHERE id_alquiler=@IdAlquiler
                  AND (total_vigente<>pagos_recibidos-reembolsos_efectivos OR reembolsos_pendientes<>0)
            )
                THROW 55274,'El alquiler no tiene saldo financiero cero o posee reembolsos pendientes.',1;

            UPDATE dbo.Alquiler
            SET fecha_cierre_financiero=SYSDATETIME()
            WHERE id_alquiler=@IdAlquiler;
        END

        COMMIT TRANSACTION;
        SELECT @IdAlquiler id_alquiler,@TipoCierre tipo_cierre,SYSDATETIME() fecha_cierre;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

GRANT EXECUTE ON OBJECT::operacion.usp_CrearReservaEquipo TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_AsignarPersonalSeguro TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_AutorizarDespacho TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_RegistrarDetalleDespacho TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_RegistrarDetalleDevolucion TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_RegistrarDetalleInspeccion TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_AutorizarReembolso TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_CerrarAlquiler TO dafel_ventas;
GRANT EXECUTE ON OBJECT::operacion.usp_CancelarAlquilerAntesDespacho TO dafel_ventas;
GO
