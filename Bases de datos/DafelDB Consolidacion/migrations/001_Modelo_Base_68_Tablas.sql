/*
  DDL base generado desde el diccionario de referencia recibido.
  Revisado y ejecutado primero en una base de validacion.
*/
USE [DafelDB_Validacion];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT N'Creando dbo.Cliente';
    CREATE TABLE dbo.[Cliente]
    (
        [id_cliente] INT IDENTITY(1,1) NOT NULL,
        [nit] VARCHAR(20) NOT NULL,
        [razon_social] NVARCHAR(200) NOT NULL,
        [telefono] VARCHAR(30) NOT NULL,
        [correo] NVARCHAR(254) NULL,
        [fecha_registro] DATETIME2(0) NOT NULL CONSTRAINT DF_Cliente_fecha_registro DEFAULT SYSDATETIME(),
        [activo] BIT NOT NULL CONSTRAINT DF_Cliente_activo DEFAULT 1,
        CONSTRAINT PK_Cliente PRIMARY KEY ([id_cliente]),
        CONSTRAINT UQ_Cliente_nit UNIQUE ([nit]),
        CONSTRAINT CK_Cliente_nit_texto CHECK (LEN(LTRIM(RTRIM([nit]))) > 0),
        CONSTRAINT CK_Cliente_razon_social_texto CHECK (LEN(LTRIM(RTRIM([razon_social]))) > 0),
        CONSTRAINT CK_Cliente_telefono_texto CHECK (LEN(LTRIM(RTRIM([telefono]))) > 0)
    );

    PRINT N'Creando dbo.Solicitud';
    CREATE TABLE dbo.[Solicitud]
    (
        [id_solicitud] INT IDENTITY(1,1) NOT NULL,
        [id_cliente] INT NOT NULL,
        [id_obra] INT NOT NULL,
        [numero_solicitud] VARCHAR(30) NOT NULL,
        [fecha_registro] DATETIME2(0) NOT NULL CONSTRAINT DF_Solicitud_fecha_registro DEFAULT SYSDATETIME(),
        [canal] VARCHAR(10) NOT NULL,
        [estado] VARCHAR(25) NOT NULL CONSTRAINT DF_Solicitud_estado DEFAULT 'RECIBIDA',
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Solicitud PRIMARY KEY ([id_solicitud]),
        CONSTRAINT UQ_Solicitud_numero_solicitud UNIQUE ([numero_solicitud]),
        CONSTRAINT CK_Solicitud_numero_solicitud_texto CHECK (LEN(LTRIM(RTRIM([numero_solicitud]))) > 0),
        CONSTRAINT CK_Solicitud_canal_texto CHECK (LEN(LTRIM(RTRIM([canal]))) > 0),
        CONSTRAINT CK_Solicitud_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_Solicitud_canal CHECK (canal IN ('WEB','WHATSAPP')),
        CONSTRAINT CK_Solicitud_estado CHECK (estado IN ('RECIBIDA','EN_REVISION','EN_COTIZACION','CONVERTIDA','RECHAZADA','CANCELADA','VENCIDA'))
    );

    PRINT N'Creando dbo.DetalleSolicitud';
    CREATE TABLE dbo.[DetalleSolicitud]
    (
        [id_detalle_solicitud] INT IDENTITY(1,1) NOT NULL,
        [id_solicitud] INT NOT NULL,
        [id_recurso] INT NOT NULL,
        [numero_linea] INT NOT NULL,
        [cantidad] INT NOT NULL,
        [fecha_inicio_solicitada] DATETIME2(0) NOT NULL,
        [fecha_fin_solicitada] DATETIME2(0) NOT NULL,
        CONSTRAINT PK_DetalleSolicitud PRIMARY KEY ([id_detalle_solicitud]),
        CONSTRAINT CK_DetalleSolicitud_numero_linea CHECK ([numero_linea] > 0),
        CONSTRAINT CK_DetalleSolicitud_cantidad CHECK ([cantidad] > 0),
        CONSTRAINT CK_DetalleSolicitud_periodo CHECK ([fecha_fin_solicitada] IS NULL OR [fecha_fin_solicitada] > [fecha_inicio_solicitada])
    );

    PRINT N'Creando dbo.Obra';
    CREATE TABLE dbo.[Obra]
    (
        [id_obra] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [direccion] NVARCHAR(250) NOT NULL,
        [ciudad] NVARCHAR(100) NOT NULL,
        [indicaciones_acceso] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Obra PRIMARY KEY ([id_obra]),
        CONSTRAINT CK_Obra_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_Obra_direccion_texto CHECK (LEN(LTRIM(RTRIM([direccion]))) > 0),
        CONSTRAINT CK_Obra_ciudad_texto CHECK (LEN(LTRIM(RTRIM([ciudad]))) > 0)
    );

    PRINT N'Creando dbo.Categoria';
    CREATE TABLE dbo.[Categoria]
    (
        [id_categoria] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [descripcion] NVARCHAR(1000) NULL,
        [activo] BIT NOT NULL CONSTRAINT DF_Categoria_activo DEFAULT 1,
        CONSTRAINT PK_Categoria PRIMARY KEY ([id_categoria]),
        CONSTRAINT UQ_Categoria_nombre UNIQUE ([nombre]),
        CONSTRAINT CK_Categoria_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0)
    );

    PRINT N'Creando dbo.Recurso';
    CREATE TABLE dbo.[Recurso]
    (
        [id_recurso] INT IDENTITY(1,1) NOT NULL,
        [id_categoria] INT NOT NULL,
        [codigo] VARCHAR(30) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [descripcion] NVARCHAR(1000) NULL,
        [naturaleza] VARCHAR(10) NOT NULL,
        [activo] BIT NOT NULL CONSTRAINT DF_Recurso_activo DEFAULT 1,
        CONSTRAINT PK_Recurso PRIMARY KEY ([id_recurso]),
        CONSTRAINT UQ_Recurso_codigo UNIQUE ([codigo]),
        CONSTRAINT CK_Recurso_codigo_texto CHECK (LEN(LTRIM(RTRIM([codigo]))) > 0),
        CONSTRAINT CK_Recurso_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_Recurso_naturaleza_texto CHECK (LEN(LTRIM(RTRIM([naturaleza]))) > 0),
        CONSTRAINT CK_Recurso_naturaleza CHECK (naturaleza IN ('EQUIPO','PERSONAL'))
    );

    PRINT N'Creando dbo.Cotizacion';
    CREATE TABLE dbo.[Cotizacion]
    (
        [id_cotizacion] INT IDENTITY(1,1) NOT NULL,
        [id_solicitud] INT NOT NULL,
        [id_usuario_autorizador] INT NULL,
        [numero_version] INT NOT NULL,
        [fecha_emision] DATETIME2(0) NULL,
        [fecha_vencimiento] DATETIME2(0) NULL,
        [fecha_autorizacion] DATETIME2(0) NULL,
        [estado] VARCHAR(25) NOT NULL,
        [fecha_respuesta] DATETIME2(0) NULL,
        [motivo_rechazo] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Cotizacion PRIMARY KEY ([id_cotizacion]),
        CONSTRAINT CK_Cotizacion_numero_version CHECK ([numero_version] > 0),
        CONSTRAINT CK_Cotizacion_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0)
    );

    PRINT N'Creando dbo.DetalleCotizacion';
    CREATE TABLE dbo.[DetalleCotizacion]
    (
        [id_detalle_cotizacion] INT IDENTITY(1,1) NOT NULL,
        [id_cotizacion] INT NOT NULL,
        [id_detalle_solicitud] INT NOT NULL,
        [id_unidad_cobro] INT NOT NULL,
        [numero_linea] INT NOT NULL,
        [cantidad_ofrecida] INT NOT NULL,
        [fecha_inicio] DATETIME2(0) NOT NULL,
        [fecha_fin] DATETIME2(0) NOT NULL,
        [tarifa_unitaria] DECIMAL(18,2) NOT NULL,
        [unidades_tiempo_cobrables] DECIMAL(12,4) NOT NULL,
        CONSTRAINT PK_DetalleCotizacion PRIMARY KEY ([id_detalle_cotizacion]),
        CONSTRAINT CK_DetalleCotizacion_numero_linea CHECK ([numero_linea] > 0),
        CONSTRAINT CK_DetalleCotizacion_cantidad_ofrecida CHECK ([cantidad_ofrecida] > 0),
        CONSTRAINT CK_DetalleCotizacion_tarifa_unitaria CHECK ([tarifa_unitaria] > 0),
        CONSTRAINT CK_DetalleCotizacion_unidades_tiempo_cobrables CHECK ([unidades_tiempo_cobrables] > 0),
        CONSTRAINT CK_DetalleCotizacion_periodo CHECK ([fecha_fin] IS NULL OR [fecha_fin] > [fecha_inicio])
    );

    PRINT N'Creando dbo.ConceptoCotizacion';
    CREATE TABLE dbo.[ConceptoCotizacion]
    (
        [id_concepto_cotizacion] INT IDENTITY(1,1) NOT NULL,
        [id_cotizacion] INT NOT NULL,
        [concepto] NVARCHAR(150) NOT NULL,
        [descripcion] NVARCHAR(1000) NULL,
        [cantidad] INT NOT NULL,
        [valor_unitario] DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_ConceptoCotizacion PRIMARY KEY ([id_concepto_cotizacion]),
        CONSTRAINT CK_ConceptoCotizacion_concepto_texto CHECK (LEN(LTRIM(RTRIM([concepto]))) > 0),
        CONSTRAINT CK_ConceptoCotizacion_cantidad CHECK ([cantidad] > 0),
        CONSTRAINT CK_ConceptoCotizacion_valor_unitario CHECK ([valor_unitario] > 0)
    );

    PRINT N'Creando dbo.TarifaRecurso';
    CREATE TABLE dbo.[TarifaRecurso]
    (
        [id_tarifa] INT IDENTITY(1,1) NOT NULL,
        [id_recurso] INT NOT NULL,
        [id_unidad_cobro] INT NOT NULL,
        [valor_unitario] DECIMAL(18,2) NOT NULL,
        [vigencia_desde] DATETIME2(0) NOT NULL,
        [vigencia_hasta] DATETIME2(0) NULL,
        CONSTRAINT PK_TarifaRecurso PRIMARY KEY ([id_tarifa]),
        CONSTRAINT CK_TarifaRecurso_valor_unitario CHECK ([valor_unitario] > 0),
        CONSTRAINT CK_TarifaRecurso_periodo CHECK ([vigencia_hasta] IS NULL OR [vigencia_hasta] > [vigencia_desde])
    );

    PRINT N'Creando dbo.UnidadCobro';
    CREATE TABLE dbo.[UnidadCobro]
    (
        [id_unidad_cobro] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [descripcion] NVARCHAR(1000) NULL,
        CONSTRAINT PK_UnidadCobro PRIMARY KEY ([id_unidad_cobro]),
        CONSTRAINT UQ_UnidadCobro_nombre UNIQUE ([nombre]),
        CONSTRAINT CK_UnidadCobro_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0)
    );

    PRINT N'Creando dbo.Alquiler';
    CREATE TABLE dbo.[Alquiler]
    (
        [id_alquiler] INT IDENTITY(1,1) NOT NULL,
        [id_cotizacion_aceptada] INT NOT NULL,
        [id_usuario_aprobador] INT NOT NULL,
        [numero_alquiler] VARCHAR(30) NOT NULL,
        [fecha_confirmacion] DATETIME2(0) NOT NULL,
        [estado_operativo] VARCHAR(25) NOT NULL,
        [fecha_cierre_operativo] DATETIME2(0) NULL,
        [fecha_cierre_financiero] DATETIME2(0) NULL,
        [fecha_limite_pago] DATETIME2(0) NULL,
        CONSTRAINT PK_Alquiler PRIMARY KEY ([id_alquiler]),
        CONSTRAINT UQ_Alquiler_id_cotizacion_aceptada UNIQUE ([id_cotizacion_aceptada]),
        CONSTRAINT UQ_Alquiler_numero_alquiler UNIQUE ([numero_alquiler]),
        CONSTRAINT CK_Alquiler_numero_alquiler_texto CHECK (LEN(LTRIM(RTRIM([numero_alquiler]))) > 0),
        CONSTRAINT CK_Alquiler_estado_operativo_texto CHECK (LEN(LTRIM(RTRIM([estado_operativo]))) > 0)
    );

    PRINT N'Creando dbo.SolicitudCambio';
    CREATE TABLE dbo.[SolicitudCambio]
    (
        [id_solicitud_cambio] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [id_usuario_decisor] INT NULL,
        [tipo_cambio] VARCHAR(30) NOT NULL,
        [fecha_solicitud] DATETIME2(0) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [fecha_decision] DATETIME2(0) NULL,
        [observaciones_decision] NVARCHAR(1000) NULL,
        [fecha_aceptacion_cliente] DATETIME2(0) NULL,
        [numero_revision_aplicada] INT NULL,
        CONSTRAINT PK_SolicitudCambio PRIMARY KEY ([id_solicitud_cambio]),
        CONSTRAINT CK_SolicitudCambio_tipo_cambio_texto CHECK (LEN(LTRIM(RTRIM([tipo_cambio]))) > 0),
        CONSTRAINT CK_SolicitudCambio_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0),
        CONSTRAINT CK_SolicitudCambio_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0)
    );

    PRINT N'Creando dbo.DetalleAlquiler';
    CREATE TABLE dbo.[DetalleAlquiler]
    (
        [id_detalle_alquiler] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_detalle_cotizacion] INT NOT NULL,
        CONSTRAINT PK_DetalleAlquiler PRIMARY KEY ([id_detalle_alquiler]),
        CONSTRAINT UQ_DetalleAlquiler_id_detalle_cotizacion UNIQUE ([id_detalle_cotizacion])
    );

    PRINT N'Creando dbo.DetalleSolicitudCambio';
    CREATE TABLE dbo.[DetalleSolicitudCambio]
    (
        [id_detalle_cambio] INT IDENTITY(1,1) NOT NULL,
        [id_solicitud_cambio] INT NOT NULL,
        [id_detalle_alquiler] INT NOT NULL,
        [cantidad_propuesta] INT NOT NULL,
        [fecha_inicio_propuesta] DATETIME2(0) NOT NULL,
        [fecha_fin_propuesta] DATETIME2(0) NOT NULL,
        CONSTRAINT PK_DetalleSolicitudCambio PRIMARY KEY ([id_detalle_cambio]),
        CONSTRAINT CK_DetalleSolicitudCambio_cantidad_propuesta CHECK ([cantidad_propuesta] >= 0),
        CONSTRAINT CK_DetalleSolicitudCambio_periodo CHECK ([fecha_fin_propuesta] IS NULL OR [fecha_fin_propuesta] > [fecha_inicio_propuesta])
    );

    PRINT N'Creando dbo.ReservaEquipo';
    CREATE TABLE dbo.[ReservaEquipo]
    (
        [id_reserva] INT IDENTITY(1,1) NOT NULL,
        [id_detalle_alquiler] INT NOT NULL,
        [id_bodega] INT NOT NULL,
        [fecha_creacion] DATETIME2(0) NOT NULL,
        CONSTRAINT PK_ReservaEquipo PRIMARY KEY ([id_reserva])
    );

    PRINT N'Creando dbo.VersionReservaEquipo';
    CREATE TABLE dbo.[VersionReservaEquipo]
    (
        [id_version_reserva] INT IDENTITY(1,1) NOT NULL,
        [id_reserva] INT NOT NULL,
        [numero_version] INT NOT NULL,
        [cantidad_comprometida] INT NOT NULL,
        [fecha_inicio] DATETIME2(0) NOT NULL,
        [fecha_fin] DATETIME2(0) NOT NULL,
        [fecha_aplicacion] DATETIME2(0) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        CONSTRAINT PK_VersionReservaEquipo PRIMARY KEY ([id_version_reserva]),
        CONSTRAINT CK_VersionReservaEquipo_numero_version CHECK ([numero_version] > 0),
        CONSTRAINT CK_VersionReservaEquipo_cantidad_comprometida CHECK ([cantidad_comprometida] > 0),
        CONSTRAINT CK_VersionReservaEquipo_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_VersionReservaEquipo_periodo CHECK ([fecha_fin] IS NULL OR [fecha_fin] > [fecha_inicio])
    );

    PRINT N'Creando dbo.Bodega';
    CREATE TABLE dbo.[Bodega]
    (
        [id_bodega] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [direccion] NVARCHAR(250) NOT NULL,
        [activo] BIT NOT NULL CONSTRAINT DF_Bodega_activo DEFAULT 1,
        CONSTRAINT PK_Bodega PRIMARY KEY ([id_bodega]),
        CONSTRAINT CK_Bodega_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_Bodega_direccion_texto CHECK (LEN(LTRIM(RTRIM([direccion]))) > 0)
    );

    PRINT N'Creando dbo.CambioVersionReserva';
    CREATE TABLE dbo.[CambioVersionReserva]
    (
        [id_version_reserva] INT NOT NULL,
        [id_solicitud_cambio] INT NOT NULL,
        CONSTRAINT PK_CambioVersionReserva PRIMARY KEY ([id_version_reserva])
    );

    PRINT N'Creando dbo.Despacho';
    CREATE TABLE dbo.[Despacho]
    (
        [id_despacho] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_autorizador] INT NOT NULL,
        [id_empleado_entrega] INT NOT NULL,
        [numero_despacho] VARCHAR(30) NOT NULL,
        [fecha_salida] DATETIME2(0) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        CONSTRAINT PK_Despacho PRIMARY KEY ([id_despacho]),
        CONSTRAINT UQ_Despacho_numero_despacho UNIQUE ([numero_despacho]),
        CONSTRAINT CK_Despacho_numero_despacho_texto CHECK (LEN(LTRIM(RTRIM([numero_despacho]))) > 0),
        CONSTRAINT CK_Despacho_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0)
    );

    PRINT N'Creando dbo.ConstanciaEntrega';
    CREATE TABLE dbo.[ConstanciaEntrega]
    (
        [id_constancia] INT IDENTITY(1,1) NOT NULL,
        [id_despacho] INT NOT NULL,
        [fecha_entrega] DATETIME2(0) NOT NULL,
        [nombre_receptor] NVARCHAR(250) NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_ConstanciaEntrega PRIMARY KEY ([id_constancia]),
        CONSTRAINT UQ_ConstanciaEntrega_id_despacho UNIQUE ([id_despacho]),
        CONSTRAINT CK_ConstanciaEntrega_nombre_receptor_texto CHECK (LEN(LTRIM(RTRIM([nombre_receptor]))) > 0)
    );

    PRINT N'Creando dbo.DetalleDespacho';
    CREATE TABLE dbo.[DetalleDespacho]
    (
        [id_detalle_despacho] INT IDENTITY(1,1) NOT NULL,
        [id_despacho] INT NOT NULL,
        [id_reserva] INT NOT NULL,
        [cantidad_despachada] INT NOT NULL,
        [observaciones_salida] NVARCHAR(1000) NULL,
        CONSTRAINT PK_DetalleDespacho PRIMARY KEY ([id_detalle_despacho]),
        CONSTRAINT CK_DetalleDespacho_cantidad_despachada CHECK ([cantidad_despachada] > 0)
    );

    PRINT N'Creando dbo.Empleado';
    CREATE TABLE dbo.[Empleado]
    (
        [id_empleado] INT IDENTITY(1,1) NOT NULL,
        [tipo_documento] VARCHAR(10) NOT NULL,
        [numero_documento] VARCHAR(30) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [telefono] VARCHAR(30) NOT NULL,
        [activo] BIT NOT NULL CONSTRAINT DF_Empleado_activo DEFAULT 1,
        CONSTRAINT PK_Empleado PRIMARY KEY ([id_empleado]),
        CONSTRAINT CK_Empleado_tipo_documento_texto CHECK (LEN(LTRIM(RTRIM([tipo_documento]))) > 0),
        CONSTRAINT CK_Empleado_numero_documento_texto CHECK (LEN(LTRIM(RTRIM([numero_documento]))) > 0),
        CONSTRAINT CK_Empleado_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_Empleado_telefono_texto CHECK (LEN(LTRIM(RTRIM([telefono]))) > 0)
    );

    PRINT N'Creando dbo.Devolucion';
    CREATE TABLE dbo.[Devolucion]
    (
        [id_devolucion] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_empleado_receptor] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [numero_devolucion] VARCHAR(30) NOT NULL,
        [fecha_recepcion] DATETIME2(0) NOT NULL,
        CONSTRAINT PK_Devolucion PRIMARY KEY ([id_devolucion]),
        CONSTRAINT UQ_Devolucion_numero_devolucion UNIQUE ([numero_devolucion]),
        CONSTRAINT CK_Devolucion_numero_devolucion_texto CHECK (LEN(LTRIM(RTRIM([numero_devolucion]))) > 0)
    );

    PRINT N'Creando dbo.Inspeccion';
    CREATE TABLE dbo.[Inspeccion]
    (
        [id_inspeccion] INT IDENTITY(1,1) NOT NULL,
        [id_devolucion] INT NOT NULL,
        [id_empleado_inspector] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_inspeccion] DATETIME2(0) NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Inspeccion PRIMARY KEY ([id_inspeccion])
    );

    PRINT N'Creando dbo.DetalleDevolucion';
    CREATE TABLE dbo.[DetalleDevolucion]
    (
        [id_detalle_devolucion] INT IDENTITY(1,1) NOT NULL,
        [id_devolucion] INT NOT NULL,
        [id_detalle_despacho] INT NOT NULL,
        [id_bodega_recepcion] INT NOT NULL,
        [cantidad_recibida] INT NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_DetalleDevolucion PRIMARY KEY ([id_detalle_devolucion]),
        CONSTRAINT CK_DetalleDevolucion_cantidad_recibida CHECK ([cantidad_recibida] > 0)
    );

    PRINT N'Creando dbo.DetalleInspeccion';
    CREATE TABLE dbo.[DetalleInspeccion]
    (
        [id_detalle_inspeccion] INT IDENTITY(1,1) NOT NULL,
        [id_inspeccion] INT NOT NULL,
        [id_detalle_devolucion] INT NOT NULL,
        [id_condicion_resultante] INT NOT NULL,
        [cantidad_revisada] INT NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_DetalleInspeccion PRIMARY KEY ([id_detalle_inspeccion]),
        CONSTRAINT CK_DetalleInspeccion_cantidad_revisada CHECK ([cantidad_revisada] > 0)
    );

    PRINT N'Creando dbo.CondicionMaterial';
    CREATE TABLE dbo.[CondicionMaterial]
    (
        [id_condicion] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [permite_despacho] BIT NOT NULL,
        CONSTRAINT PK_CondicionMaterial PRIMARY KEY ([id_condicion]),
        CONSTRAINT UQ_CondicionMaterial_nombre UNIQUE ([nombre]),
        CONSTRAINT CK_CondicionMaterial_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0)
    );

    PRINT N'Creando dbo.TipoMovimiento';
    CREATE TABLE dbo.[TipoMovimiento]
    (
        [id_tipo_movimiento] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [descripcion] NVARCHAR(1000) NOT NULL,
        CONSTRAINT PK_TipoMovimiento PRIMARY KEY ([id_tipo_movimiento]),
        CONSTRAINT UQ_TipoMovimiento_nombre UNIQUE ([nombre]),
        CONSTRAINT CK_TipoMovimiento_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_TipoMovimiento_descripcion_texto CHECK (LEN(LTRIM(RTRIM([descripcion]))) > 0)
    );

    PRINT N'Creando dbo.MovimientoInventario';
    CREATE TABLE dbo.[MovimientoInventario]
    (
        [id_movimiento] INT IDENTITY(1,1) NOT NULL,
        [id_tipo_movimiento] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_movimiento] DATETIME2(0) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        CONSTRAINT PK_MovimientoInventario PRIMARY KEY ([id_movimiento]),
        CONSTRAINT CK_MovimientoInventario_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0)
    );

    PRINT N'Creando dbo.DetalleMovimientoInventario';
    CREATE TABLE dbo.[DetalleMovimientoInventario]
    (
        [id_detalle_movimiento] INT IDENTITY(1,1) NOT NULL,
        [id_movimiento] INT NOT NULL,
        [id_recurso] INT NOT NULL,
        [id_bodega] INT NOT NULL,
        [id_condicion] INT NOT NULL,
        [cantidad_variacion] INT NOT NULL,
        CONSTRAINT PK_DetalleMovimientoInventario PRIMARY KEY ([id_detalle_movimiento]),
        CONSTRAINT CK_DetalleMovimientoInventario_cantidad_variacion CHECK ([cantidad_variacion] <> 0)
    );

    PRINT N'Creando dbo.RevisionMaterial';
    CREATE TABLE dbo.[RevisionMaterial]
    (
        [id_revision_material] INT IDENTITY(1,1) NOT NULL,
        [id_recurso] INT NOT NULL,
        [id_bodega] INT NOT NULL,
        [id_condicion_origen] INT NOT NULL,
        [id_condicion_destino] INT NOT NULL,
        [id_empleado_revisor] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [cantidad] INT NOT NULL,
        [fecha_revision] DATETIME2(0) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        CONSTRAINT PK_RevisionMaterial PRIMARY KEY ([id_revision_material]),
        CONSTRAINT CK_RevisionMaterial_cantidad CHECK ([cantidad] > 0),
        CONSTRAINT CK_RevisionMaterial_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0)
    );

    PRINT N'Creando dbo.MovimientoDespacho';
    CREATE TABLE dbo.[MovimientoDespacho]
    (
        [id_movimiento] INT NOT NULL,
        [id_detalle_despacho] INT NOT NULL,
        CONSTRAINT PK_MovimientoDespacho PRIMARY KEY ([id_movimiento]),
        CONSTRAINT UQ_MovimientoDespacho_id_detalle_despacho UNIQUE ([id_detalle_despacho])
    );

    PRINT N'Creando dbo.MovimientoDevolucion';
    CREATE TABLE dbo.[MovimientoDevolucion]
    (
        [id_movimiento] INT NOT NULL,
        [id_detalle_devolucion] INT NOT NULL,
        CONSTRAINT PK_MovimientoDevolucion PRIMARY KEY ([id_movimiento]),
        CONSTRAINT UQ_MovimientoDevolucion_id_detalle_devolucion UNIQUE ([id_detalle_devolucion])
    );

    PRINT N'Creando dbo.MovimientoInspeccion';
    CREATE TABLE dbo.[MovimientoInspeccion]
    (
        [id_movimiento] INT NOT NULL,
        [id_detalle_inspeccion] INT NOT NULL,
        CONSTRAINT PK_MovimientoInspeccion PRIMARY KEY ([id_movimiento]),
        CONSTRAINT UQ_MovimientoInspeccion_id_detalle_inspeccion UNIQUE ([id_detalle_inspeccion])
    );

    PRINT N'Creando dbo.MovimientoRevisionMaterial';
    CREATE TABLE dbo.[MovimientoRevisionMaterial]
    (
        [id_movimiento] INT NOT NULL,
        [id_revision_material] INT NOT NULL,
        CONSTRAINT PK_MovimientoRevisionMaterial PRIMARY KEY ([id_movimiento]),
        CONSTRAINT UQ_MovimientoRevisionMaterial_id_revision_material UNIQUE ([id_revision_material])
    );

    PRINT N'Creando dbo.IncidenciaAlquiler';
    CREATE TABLE dbo.[IncidenciaAlquiler]
    (
        [id_incidencia] INT IDENTITY(1,1) NOT NULL,
        [id_detalle_alquiler] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [tipo] VARCHAR(40) NOT NULL,
        [cantidad_afectada] INT NOT NULL,
        [fecha_registro] DATETIME2(0) NOT NULL CONSTRAINT DF_IncidenciaAlquiler_fecha_registro DEFAULT SYSDATETIME(),
        [descripcion] NVARCHAR(1000) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [resolucion] NVARCHAR(1000) NULL,
        [fecha_resolucion] DATETIME2(0) NULL,
        [costo_estimado] DECIMAL(18,2) NULL,
        [responsabilidad_acordada] NVARCHAR(1000) NULL,
        [fecha_evaluacion] DATETIME2(0) NULL,
        CONSTRAINT PK_IncidenciaAlquiler PRIMARY KEY ([id_incidencia]),
        CONSTRAINT CK_IncidenciaAlquiler_tipo_texto CHECK (LEN(LTRIM(RTRIM([tipo]))) > 0),
        CONSTRAINT CK_IncidenciaAlquiler_cantidad_afectada CHECK ([cantidad_afectada] > 0),
        CONSTRAINT CK_IncidenciaAlquiler_descripcion_texto CHECK (LEN(LTRIM(RTRIM([descripcion]))) > 0),
        CONSTRAINT CK_IncidenciaAlquiler_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_Incidencia_costo_estimado CHECK (costo_estimado IS NULL OR costo_estimado >= 0)
    );

    PRINT N'Creando dbo.IncidenciaInspeccion';
    CREATE TABLE dbo.[IncidenciaInspeccion]
    (
        [id_incidencia] INT NOT NULL,
        [id_detalle_inspeccion] INT NOT NULL,
        CONSTRAINT PK_IncidenciaInspeccion PRIMARY KEY ([id_incidencia], [id_detalle_inspeccion])
    );

    PRINT N'Creando dbo.CargoIncidencia';
    CREATE TABLE dbo.[CargoIncidencia]
    (
        [id_cargo] INT NOT NULL,
        [id_incidencia] INT NOT NULL,
        CONSTRAINT PK_CargoIncidencia PRIMARY KEY ([id_cargo])
    );

    PRINT N'Creando dbo.CargoAlquiler';
    CREATE TABLE dbo.[CargoAlquiler]
    (
        [id_cargo] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_autorizador] INT NOT NULL,
        [concepto] NVARCHAR(150) NOT NULL,
        [importe] DECIMAL(18,2) NOT NULL,
        [fecha_autorizacion] DATETIME2(0) NOT NULL,
        [justificacion] NVARCHAR(1000) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [id_usuario_anulacion] INT NULL,
        [fecha_anulacion] DATETIME2(0) NULL,
        [motivo_anulacion] NVARCHAR(1000) NULL,
        CONSTRAINT PK_CargoAlquiler PRIMARY KEY ([id_cargo]),
        CONSTRAINT CK_CargoAlquiler_concepto_texto CHECK (LEN(LTRIM(RTRIM([concepto]))) > 0),
        CONSTRAINT CK_CargoAlquiler_importe CHECK ([importe] > 0),
        CONSTRAINT CK_CargoAlquiler_justificacion_texto CHECK (LEN(LTRIM(RTRIM([justificacion]))) > 0),
        CONSTRAINT CK_CargoAlquiler_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_CargoAlquiler_anulacion CHECK ((estado = 'ANULADO' AND id_usuario_anulacion IS NOT NULL AND fecha_anulacion IS NOT NULL AND motivo_anulacion IS NOT NULL) OR (estado = 'VIGENTE' AND id_usuario_anulacion IS NULL AND fecha_anulacion IS NULL AND motivo_anulacion IS NULL))
    );

    PRINT N'Creando dbo.EmpleadoServicio';
    CREATE TABLE dbo.[EmpleadoServicio]
    (
        [id_empleado] INT NOT NULL,
        [id_recurso] INT NOT NULL,
        CONSTRAINT PK_EmpleadoServicio PRIMARY KEY ([id_empleado], [id_recurso])
    );

    PRINT N'Creando dbo.AsignacionPersonal';
    CREATE TABLE dbo.[AsignacionPersonal]
    (
        [id_asignacion] INT IDENTITY(1,1) NOT NULL,
        [id_detalle_alquiler] INT NOT NULL,
        [id_empleado] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_inicio] DATETIME2(0) NOT NULL,
        [fecha_fin] DATETIME2(0) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        CONSTRAINT PK_AsignacionPersonal PRIMARY KEY ([id_asignacion]),
        CONSTRAINT CK_AsignacionPersonal_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_AsignacionPersonal_periodo CHECK ([fecha_fin] IS NULL OR [fecha_fin] > [fecha_inicio])
    );

    PRINT N'Creando dbo.IndisponibilidadPersonal';
    CREATE TABLE dbo.[IndisponibilidadPersonal]
    (
        [id_indisponibilidad] INT IDENTITY(1,1) NOT NULL,
        [id_empleado] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_inicio] DATETIME2(0) NOT NULL,
        [fecha_fin] DATETIME2(0) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        CONSTRAINT PK_IndisponibilidadPersonal PRIMARY KEY ([id_indisponibilidad]),
        CONSTRAINT CK_IndisponibilidadPersonal_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0),
        CONSTRAINT CK_IndisponibilidadPersonal_periodo CHECK ([fecha_fin] IS NULL OR [fecha_fin] > [fecha_inicio])
    );

    PRINT N'Creando dbo.RegistroServicioPersonal';
    CREATE TABLE dbo.[RegistroServicioPersonal]
    (
        [id_registro_servicio] INT IDENTITY(1,1) NOT NULL,
        [id_asignacion] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_hora_inicio_real] DATETIME2(0) NULL,
        [fecha_hora_fin_real] DATETIME2(0) NULL,
        [estado] VARCHAR(25) NOT NULL,
        [observaciones] NVARCHAR(1000) NULL,
        [nombre_contacto_cliente] NVARCHAR(250) NULL,
        CONSTRAINT PK_RegistroServicioPersonal PRIMARY KEY ([id_registro_servicio]),
        CONSTRAINT CK_RegistroServicioPersonal_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0)
    );

    PRINT N'Creando dbo.Usuario';
    CREATE TABLE dbo.[Usuario]
    (
        [id_usuario] INT IDENTITY(1,1) NOT NULL,
        [id_empleado] INT NOT NULL,
        [nombre_usuario] NVARCHAR(100) NOT NULL,
        [hash_contrasena] VARCHAR(255) NOT NULL,
        [activo] BIT NOT NULL CONSTRAINT DF_Usuario_activo DEFAULT 1,
        CONSTRAINT PK_Usuario PRIMARY KEY ([id_usuario]),
        CONSTRAINT UQ_Usuario_id_empleado UNIQUE ([id_empleado]),
        CONSTRAINT UQ_Usuario_nombre_usuario UNIQUE ([nombre_usuario]),
        CONSTRAINT CK_Usuario_nombre_usuario_texto CHECK (LEN(LTRIM(RTRIM([nombre_usuario]))) > 0),
        CONSTRAINT CK_Usuario_hash_contrasena_texto CHECK (LEN(LTRIM(RTRIM([hash_contrasena]))) > 0)
    );

    PRINT N'Creando dbo.UsuarioRol';
    CREATE TABLE dbo.[UsuarioRol]
    (
        [id_usuario] INT NOT NULL,
        [id_rol] INT NOT NULL,
        CONSTRAINT PK_UsuarioRol PRIMARY KEY ([id_usuario], [id_rol])
    );

    PRINT N'Creando dbo.Rol';
    CREATE TABLE dbo.[Rol]
    (
        [id_rol] INT IDENTITY(1,1) NOT NULL,
        [nombre] NVARCHAR(200) NOT NULL,
        [descripcion] NVARCHAR(1000) NOT NULL,
        CONSTRAINT PK_Rol PRIMARY KEY ([id_rol]),
        CONSTRAINT UQ_Rol_nombre UNIQUE ([nombre]),
        CONSTRAINT CK_Rol_nombre_texto CHECK (LEN(LTRIM(RTRIM([nombre]))) > 0),
        CONSTRAINT CK_Rol_descripcion_texto CHECK (LEN(LTRIM(RTRIM([descripcion]))) > 0)
    );

    PRINT N'Creando dbo.RevisionSolicitud';
    CREATE TABLE dbo.[RevisionSolicitud]
    (
        [id_revision] INT IDENTITY(1,1) NOT NULL,
        [id_solicitud] INT NOT NULL,
        [id_usuario_revisor] INT NOT NULL,
        [fecha_revision] DATETIME2(0) NOT NULL,
        [resultado] NVARCHAR(250) NOT NULL,
        [observaciones] NVARCHAR(1000) NOT NULL,
        CONSTRAINT PK_RevisionSolicitud PRIMARY KEY ([id_revision]),
        CONSTRAINT CK_RevisionSolicitud_resultado_texto CHECK (LEN(LTRIM(RTRIM([resultado]))) > 0),
        CONSTRAINT CK_RevisionSolicitud_observaciones_texto CHECK (LEN(LTRIM(RTRIM([observaciones]))) > 0)
    );

    PRINT N'Creando dbo.EvaluacionDisponibilidad';
    CREATE TABLE dbo.[EvaluacionDisponibilidad]
    (
        [id_evaluacion] INT IDENTITY(1,1) NOT NULL,
        [id_solicitud] INT NOT NULL,
        [id_usuario_evaluador] INT NOT NULL,
        [fecha_evaluacion] DATETIME2(0) NOT NULL,
        CONSTRAINT PK_EvaluacionDisponibilidad PRIMARY KEY ([id_evaluacion])
    );

    PRINT N'Creando dbo.DetalleEvaluacionDisponibilidad';
    CREATE TABLE dbo.[DetalleEvaluacionDisponibilidad]
    (
        [id_detalle_evaluacion] INT IDENTITY(1,1) NOT NULL,
        [id_evaluacion] INT NOT NULL,
        [id_detalle_solicitud] INT NOT NULL,
        [cantidad_solicitada_evaluada] INT NOT NULL,
        [cantidad_disponible] INT NOT NULL,
        [fecha_inicio_evaluada] DATETIME2(0) NOT NULL,
        [fecha_fin_evaluada] DATETIME2(0) NOT NULL,
        [depende_de_devoluciones] BIT NOT NULL,
        [motivo_no_atencion] NVARCHAR(1000) NULL,
        [alternativa_propuesta] NVARCHAR(1000) NULL,
        [decision_cliente] VARCHAR(20) NULL,
        [fecha_decision_cliente] DATETIME2(0) NULL,
        CONSTRAINT PK_DetalleEvaluacionDisponibilidad PRIMARY KEY ([id_detalle_evaluacion]),
        CONSTRAINT CK_DetalleEvaluacionDisponibilidad_cantidad_solicitada_evaluada CHECK ([cantidad_solicitada_evaluada] >= 0),
        CONSTRAINT CK_DetalleEvaluacionDisponibilidad_cantidad_disponible CHECK ([cantidad_disponible] >= 0),
        CONSTRAINT CK_DetalleEvaluacionDisponibilidad_periodo CHECK ([fecha_fin_evaluada] IS NULL OR [fecha_fin_evaluada] > [fecha_inicio_evaluada]),
        CONSTRAINT CK_Evaluacion_decision_cliente CHECK (decision_cliente IS NULL OR decision_cliente IN ('PENDIENTE','ACEPTA','RECHAZA','SIN_RESPUESTA'))
    );

    PRINT N'Creando dbo.AjusteEconomicoAlquiler';
    CREATE TABLE dbo.[AjusteEconomicoAlquiler]
    (
        [id_ajuste] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_autorizador] INT NOT NULL,
        [tipo_ajuste] VARCHAR(20) NOT NULL,
        [importe] DECIMAL(18,2) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        [fecha_autorizacion] DATETIME2(0) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [id_usuario_anulacion] INT NULL,
        [fecha_anulacion] DATETIME2(0) NULL,
        [motivo_anulacion] NVARCHAR(1000) NULL,
        CONSTRAINT PK_AjusteEconomicoAlquiler PRIMARY KEY ([id_ajuste]),
        CONSTRAINT CK_AjusteEconomicoAlquiler_tipo_ajuste_texto CHECK (LEN(LTRIM(RTRIM([tipo_ajuste]))) > 0),
        CONSTRAINT CK_AjusteEconomicoAlquiler_importe CHECK ([importe] > 0),
        CONSTRAINT CK_AjusteEconomicoAlquiler_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0),
        CONSTRAINT CK_AjusteEconomicoAlquiler_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_Ajuste_tipo CHECK (tipo_ajuste IN ('INCREMENTO','REDUCCION')),
        CONSTRAINT CK_AjusteEconomicoAlquiler_anulacion CHECK ((estado = 'ANULADO' AND id_usuario_anulacion IS NOT NULL AND fecha_anulacion IS NOT NULL AND motivo_anulacion IS NOT NULL) OR (estado = 'VIGENTE' AND id_usuario_anulacion IS NULL AND fecha_anulacion IS NULL AND motivo_anulacion IS NULL))
    );

    PRINT N'Creando dbo.AjusteSolicitudCambio';
    CREATE TABLE dbo.[AjusteSolicitudCambio]
    (
        [id_ajuste] INT NOT NULL,
        [id_solicitud_cambio] INT NOT NULL,
        CONSTRAINT PK_AjusteSolicitudCambio PRIMARY KEY ([id_ajuste])
    );

    PRINT N'Creando dbo.Pago';
    CREATE TABLE dbo.[Pago]
    (
        [id_pago] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [fecha_pago] DATETIME2(0) NOT NULL,
        [importe] DECIMAL(18,2) NOT NULL,
        [medio_pago] VARCHAR(30) NOT NULL,
        [referencia_transaccion] NVARCHAR(100) NULL,
        [fecha_registro] DATETIME2(0) NOT NULL CONSTRAINT DF_Pago_fecha_registro DEFAULT SYSDATETIME(),
        [estado] VARCHAR(25) NOT NULL,
        [id_usuario_anulacion] INT NULL,
        [fecha_anulacion] DATETIME2(0) NULL,
        [motivo_anulacion] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Pago PRIMARY KEY ([id_pago]),
        CONSTRAINT CK_Pago_importe CHECK ([importe] > 0),
        CONSTRAINT CK_Pago_medio_pago_texto CHECK (LEN(LTRIM(RTRIM([medio_pago]))) > 0),
        CONSTRAINT CK_Pago_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_Pago_anulacion CHECK ((estado = 'ANULADO' AND id_usuario_anulacion IS NOT NULL AND fecha_anulacion IS NOT NULL AND motivo_anulacion IS NOT NULL) OR (estado = 'VIGENTE' AND id_usuario_anulacion IS NULL AND fecha_anulacion IS NULL AND motivo_anulacion IS NULL))
    );

    PRINT N'Creando dbo.Reembolso';
    CREATE TABLE dbo.[Reembolso]
    (
        [id_reembolso] INT IDENTITY(1,1) NOT NULL,
        [id_alquiler] INT NOT NULL,
        [id_usuario_autorizador] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [importe] DECIMAL(18,2) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [fecha_autorizacion] DATETIME2(0) NOT NULL,
        [fecha_efectiva] DATETIME2(0) NULL,
        [referencia_transaccion] NVARCHAR(100) NULL,
        [id_usuario_anulacion] INT NULL,
        [fecha_anulacion] DATETIME2(0) NULL,
        [motivo_anulacion] NVARCHAR(1000) NULL,
        CONSTRAINT PK_Reembolso PRIMARY KEY ([id_reembolso]),
        CONSTRAINT CK_Reembolso_importe CHECK ([importe] > 0),
        CONSTRAINT CK_Reembolso_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0),
        CONSTRAINT CK_Reembolso_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0)
    );

    PRINT N'Creando dbo.ActividadCliente';
    CREATE TABLE dbo.[ActividadCliente]
    (
        [id_actividad] INT NOT NULL,
        [id_cliente] INT NOT NULL,
        CONSTRAINT PK_ActividadCliente PRIMARY KEY ([id_actividad])
    );

    PRINT N'Creando dbo.ActividadSeguimiento';
    CREATE TABLE dbo.[ActividadSeguimiento]
    (
        [id_actividad] INT IDENTITY(1,1) NOT NULL,
        [id_empleado_responsable] INT NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [tipo] VARCHAR(40) NOT NULL,
        [fecha_hora_programada] DATETIME2(0) NOT NULL,
        [estado] VARCHAR(25) NOT NULL,
        [motivo] NVARCHAR(1000) NOT NULL,
        [resultado] NVARCHAR(250) NULL,
        CONSTRAINT PK_ActividadSeguimiento PRIMARY KEY ([id_actividad]),
        CONSTRAINT CK_ActividadSeguimiento_tipo_texto CHECK (LEN(LTRIM(RTRIM([tipo]))) > 0),
        CONSTRAINT CK_ActividadSeguimiento_estado_texto CHECK (LEN(LTRIM(RTRIM([estado]))) > 0),
        CONSTRAINT CK_ActividadSeguimiento_motivo_texto CHECK (LEN(LTRIM(RTRIM([motivo]))) > 0)
    );

    PRINT N'Creando dbo.ActividadSolicitud';
    CREATE TABLE dbo.[ActividadSolicitud]
    (
        [id_actividad] INT NOT NULL,
        [id_solicitud] INT NOT NULL,
        CONSTRAINT PK_ActividadSolicitud PRIMARY KEY ([id_actividad])
    );

    PRINT N'Creando dbo.Documento';
    CREATE TABLE dbo.[Documento]
    (
        [id_documento] INT IDENTITY(1,1) NOT NULL,
        [id_usuario_registro] INT NOT NULL,
        [nombre_archivo] NVARCHAR(250) NOT NULL,
        [ubicacion_archivo] NVARCHAR(1000) NOT NULL,
        [tipo_archivo] NVARCHAR(250) NOT NULL,
        [fecha_registro] DATETIME2(0) NOT NULL CONSTRAINT DF_Documento_fecha_registro DEFAULT SYSDATETIME(),
        CONSTRAINT PK_Documento PRIMARY KEY ([id_documento]),
        CONSTRAINT CK_Documento_nombre_archivo_texto CHECK (LEN(LTRIM(RTRIM([nombre_archivo]))) > 0),
        CONSTRAINT CK_Documento_ubicacion_archivo_texto CHECK (LEN(LTRIM(RTRIM([ubicacion_archivo]))) > 0),
        CONSTRAINT CK_Documento_tipo_archivo_texto CHECK (LEN(LTRIM(RTRIM([tipo_archivo]))) > 0)
    );

    PRINT N'Creando dbo.RevisionDocumento';
    CREATE TABLE dbo.[RevisionDocumento]
    (
        [id_revision] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_RevisionDocumento PRIMARY KEY ([id_revision], [id_documento])
    );

    PRINT N'Creando dbo.DespachoDetalleDocumento';
    CREATE TABLE dbo.[DespachoDetalleDocumento]
    (
        [id_detalle_despacho] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_DespachoDetalleDocumento PRIMARY KEY ([id_detalle_despacho], [id_documento])
    );

    PRINT N'Creando dbo.EntregaDocumento';
    CREATE TABLE dbo.[EntregaDocumento]
    (
        [id_constancia] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_EntregaDocumento PRIMARY KEY ([id_constancia], [id_documento])
    );

    PRINT N'Creando dbo.InspeccionDetalleDocumento';
    CREATE TABLE dbo.[InspeccionDetalleDocumento]
    (
        [id_detalle_inspeccion] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_InspeccionDetalleDocumento PRIMARY KEY ([id_detalle_inspeccion], [id_documento])
    );

    PRINT N'Creando dbo.RevisionMaterialDocumento';
    CREATE TABLE dbo.[RevisionMaterialDocumento]
    (
        [id_revision_material] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_RevisionMaterialDocumento PRIMARY KEY ([id_revision_material], [id_documento])
    );

    PRINT N'Creando dbo.IncidenciaDocumento';
    CREATE TABLE dbo.[IncidenciaDocumento]
    (
        [id_incidencia] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_IncidenciaDocumento PRIMARY KEY ([id_incidencia], [id_documento])
    );

    PRINT N'Creando dbo.PagoDocumento';
    CREATE TABLE dbo.[PagoDocumento]
    (
        [id_pago] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_PagoDocumento PRIMARY KEY ([id_pago], [id_documento])
    );

    PRINT N'Creando dbo.ReembolsoDocumento';
    CREATE TABLE dbo.[ReembolsoDocumento]
    (
        [id_reembolso] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_ReembolsoDocumento PRIMARY KEY ([id_reembolso], [id_documento])
    );

    PRINT N'Creando dbo.Auditoria';
    CREATE TABLE dbo.[Auditoria]
    (
        [id_auditoria] BIGINT IDENTITY(1,1) NOT NULL,
        [fecha] DATETIME2(0) NOT NULL CONSTRAINT DF_Auditoria_fecha DEFAULT SYSDATETIME(),
        [tabla] SYSNAME NOT NULL,
        [operacion] VARCHAR(10) NOT NULL,
        [usuario_sql] SYSNAME NOT NULL CONSTRAINT DF_Auditoria_usuario_sql DEFAULT ORIGINAL_LOGIN(),
        [usuario_aplicacion] NVARCHAR(100) NULL,
        [datos_anteriores] NVARCHAR(MAX) NULL,
        [datos_nuevos] NVARCHAR(MAX) NULL,
        CONSTRAINT PK_Auditoria PRIMARY KEY (id_auditoria)
    );

    PRINT N'Creando dbo.DevolucionDocumento';
    CREATE TABLE dbo.[DevolucionDocumento]
    (
        [id_devolucion] INT NOT NULL,
        [id_documento] INT NOT NULL,
        CONSTRAINT PK_DevolucionDocumento PRIMARY KEY (id_devolucion,id_documento)
    );

    ALTER TABLE dbo.[Recurso] WITH CHECK
        ADD CONSTRAINT [FK_Recurso_id_categoria]
        FOREIGN KEY ([id_categoria])
        REFERENCES dbo.[Categoria] ([id_categoria]);

    ALTER TABLE dbo.[Solicitud] WITH CHECK
        ADD CONSTRAINT [FK_Solicitud_id_cliente]
        FOREIGN KEY ([id_cliente])
        REFERENCES dbo.[Cliente] ([id_cliente]);

    ALTER TABLE dbo.[Solicitud] WITH CHECK
        ADD CONSTRAINT [FK_Solicitud_id_obra]
        FOREIGN KEY ([id_obra])
        REFERENCES dbo.[Obra] ([id_obra]);

    ALTER TABLE dbo.[DetalleSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_DetalleSolicitud_id_solicitud]
        FOREIGN KEY ([id_solicitud])
        REFERENCES dbo.[Solicitud] ([id_solicitud]);

    ALTER TABLE dbo.[DetalleSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_DetalleSolicitud_id_recurso]
        FOREIGN KEY ([id_recurso])
        REFERENCES dbo.[Recurso] ([id_recurso]);

    ALTER TABLE dbo.[TarifaRecurso] WITH CHECK
        ADD CONSTRAINT [FK_TarifaRecurso_id_recurso]
        FOREIGN KEY ([id_recurso])
        REFERENCES dbo.[Recurso] ([id_recurso]);

    ALTER TABLE dbo.[TarifaRecurso] WITH CHECK
        ADD CONSTRAINT [FK_TarifaRecurso_id_unidad_cobro]
        FOREIGN KEY ([id_unidad_cobro])
        REFERENCES dbo.[UnidadCobro] ([id_unidad_cobro]);

    ALTER TABLE dbo.[Cotizacion] WITH CHECK
        ADD CONSTRAINT [FK_Cotizacion_id_solicitud]
        FOREIGN KEY ([id_solicitud])
        REFERENCES dbo.[Solicitud] ([id_solicitud]);

    ALTER TABLE dbo.[DetalleCotizacion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleCotizacion_id_cotizacion]
        FOREIGN KEY ([id_cotizacion])
        REFERENCES dbo.[Cotizacion] ([id_cotizacion]);

    ALTER TABLE dbo.[DetalleCotizacion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleCotizacion_id_detalle_solicitud]
        FOREIGN KEY ([id_detalle_solicitud])
        REFERENCES dbo.[DetalleSolicitud] ([id_detalle_solicitud]);

    ALTER TABLE dbo.[DetalleCotizacion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleCotizacion_id_unidad_cobro]
        FOREIGN KEY ([id_unidad_cobro])
        REFERENCES dbo.[UnidadCobro] ([id_unidad_cobro]);

    ALTER TABLE dbo.[ConceptoCotizacion] WITH CHECK
        ADD CONSTRAINT [FK_ConceptoCotizacion_id_cotizacion]
        FOREIGN KEY ([id_cotizacion])
        REFERENCES dbo.[Cotizacion] ([id_cotizacion]);

    ALTER TABLE dbo.[DetalleAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_DetalleAlquiler_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[SolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_SolicitudCambio_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[DetalleSolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_DetalleSolicitudCambio_id_solicitud_cambio]
        FOREIGN KEY ([id_solicitud_cambio])
        REFERENCES dbo.[SolicitudCambio] ([id_solicitud_cambio]);

    ALTER TABLE dbo.[DetalleSolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_DetalleSolicitudCambio_id_detalle_alquiler]
        FOREIGN KEY ([id_detalle_alquiler])
        REFERENCES dbo.[DetalleAlquiler] ([id_detalle_alquiler]);

    ALTER TABLE dbo.[Alquiler] WITH CHECK
        ADD CONSTRAINT [FK_Alquiler_id_cotizacion_aceptada]
        FOREIGN KEY ([id_cotizacion_aceptada])
        REFERENCES dbo.[Cotizacion] ([id_cotizacion]);

    ALTER TABLE dbo.[DetalleAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_DetalleAlquiler_id_detalle_cotizacion]
        FOREIGN KEY ([id_detalle_cotizacion])
        REFERENCES dbo.[DetalleCotizacion] ([id_detalle_cotizacion]);

    ALTER TABLE dbo.[ReservaEquipo] WITH CHECK
        ADD CONSTRAINT [FK_ReservaEquipo_id_detalle_alquiler]
        FOREIGN KEY ([id_detalle_alquiler])
        REFERENCES dbo.[DetalleAlquiler] ([id_detalle_alquiler]);

    ALTER TABLE dbo.[ReservaEquipo] WITH CHECK
        ADD CONSTRAINT [FK_ReservaEquipo_id_bodega]
        FOREIGN KEY ([id_bodega])
        REFERENCES dbo.[Bodega] ([id_bodega]);

    ALTER TABLE dbo.[VersionReservaEquipo] WITH CHECK
        ADD CONSTRAINT [FK_VersionReservaEquipo_id_reserva]
        FOREIGN KEY ([id_reserva])
        REFERENCES dbo.[ReservaEquipo] ([id_reserva]);

    ALTER TABLE dbo.[CambioVersionReserva] WITH CHECK
        ADD CONSTRAINT [FK_CambioVersionReserva_id_solicitud_cambio]
        FOREIGN KEY ([id_solicitud_cambio])
        REFERENCES dbo.[SolicitudCambio] ([id_solicitud_cambio]);

    ALTER TABLE dbo.[CambioVersionReserva] WITH CHECK
        ADD CONSTRAINT [FK_CambioVersionReserva_id_version_reserva]
        FOREIGN KEY ([id_version_reserva])
        REFERENCES dbo.[VersionReservaEquipo] ([id_version_reserva]);

    ALTER TABLE dbo.[Despacho] WITH CHECK
        ADD CONSTRAINT [FK_Despacho_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[DetalleDespacho] WITH CHECK
        ADD CONSTRAINT [FK_DetalleDespacho_id_despacho]
        FOREIGN KEY ([id_despacho])
        REFERENCES dbo.[Despacho] ([id_despacho]);

    ALTER TABLE dbo.[DetalleDespacho] WITH CHECK
        ADD CONSTRAINT [FK_DetalleDespacho_id_reserva]
        FOREIGN KEY ([id_reserva])
        REFERENCES dbo.[ReservaEquipo] ([id_reserva]);

    ALTER TABLE dbo.[ConstanciaEntrega] WITH CHECK
        ADD CONSTRAINT [FK_ConstanciaEntrega_id_despacho]
        FOREIGN KEY ([id_despacho])
        REFERENCES dbo.[Despacho] ([id_despacho]);

    ALTER TABLE dbo.[Devolucion] WITH CHECK
        ADD CONSTRAINT [FK_Devolucion_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[DetalleDevolucion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleDevolucion_id_devolucion]
        FOREIGN KEY ([id_devolucion])
        REFERENCES dbo.[Devolucion] ([id_devolucion]);

    ALTER TABLE dbo.[DetalleDevolucion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleDevolucion_id_detalle_despacho]
        FOREIGN KEY ([id_detalle_despacho])
        REFERENCES dbo.[DetalleDespacho] ([id_detalle_despacho]);

    ALTER TABLE dbo.[DetalleDevolucion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleDevolucion_id_bodega_recepcion]
        FOREIGN KEY ([id_bodega_recepcion])
        REFERENCES dbo.[Bodega] ([id_bodega]);

    ALTER TABLE dbo.[Inspeccion] WITH CHECK
        ADD CONSTRAINT [FK_Inspeccion_id_devolucion]
        FOREIGN KEY ([id_devolucion])
        REFERENCES dbo.[Devolucion] ([id_devolucion]);

    ALTER TABLE dbo.[DetalleInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleInspeccion_id_inspeccion]
        FOREIGN KEY ([id_inspeccion])
        REFERENCES dbo.[Inspeccion] ([id_inspeccion]);

    ALTER TABLE dbo.[DetalleInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleInspeccion_id_detalle_devolucion]
        FOREIGN KEY ([id_detalle_devolucion])
        REFERENCES dbo.[DetalleDevolucion] ([id_detalle_devolucion]);

    ALTER TABLE dbo.[DetalleInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_DetalleInspeccion_id_condicion_resultante]
        FOREIGN KEY ([id_condicion_resultante])
        REFERENCES dbo.[CondicionMaterial] ([id_condicion]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_recurso]
        FOREIGN KEY ([id_recurso])
        REFERENCES dbo.[Recurso] ([id_recurso]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_bodega]
        FOREIGN KEY ([id_bodega])
        REFERENCES dbo.[Bodega] ([id_bodega]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_condicion_origen]
        FOREIGN KEY ([id_condicion_origen])
        REFERENCES dbo.[CondicionMaterial] ([id_condicion]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_condicion_destino]
        FOREIGN KEY ([id_condicion_destino])
        REFERENCES dbo.[CondicionMaterial] ([id_condicion]);

    ALTER TABLE dbo.[MovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoInventario_id_tipo_movimiento]
        FOREIGN KEY ([id_tipo_movimiento])
        REFERENCES dbo.[TipoMovimiento] ([id_tipo_movimiento]);

    ALTER TABLE dbo.[DetalleMovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_DetalleMovimientoInventario_id_movimiento]
        FOREIGN KEY ([id_movimiento])
        REFERENCES dbo.[MovimientoInventario] ([id_movimiento]);

    ALTER TABLE dbo.[DetalleMovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_DetalleMovimientoInventario_id_recurso]
        FOREIGN KEY ([id_recurso])
        REFERENCES dbo.[Recurso] ([id_recurso]);

    ALTER TABLE dbo.[DetalleMovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_DetalleMovimientoInventario_id_bodega]
        FOREIGN KEY ([id_bodega])
        REFERENCES dbo.[Bodega] ([id_bodega]);

    ALTER TABLE dbo.[DetalleMovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_DetalleMovimientoInventario_id_condicion]
        FOREIGN KEY ([id_condicion])
        REFERENCES dbo.[CondicionMaterial] ([id_condicion]);

    ALTER TABLE dbo.[MovimientoDespacho] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoDespacho_id_movimiento]
        FOREIGN KEY ([id_movimiento])
        REFERENCES dbo.[MovimientoInventario] ([id_movimiento]);

    ALTER TABLE dbo.[MovimientoDespacho] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoDespacho_id_detalle_despacho]
        FOREIGN KEY ([id_detalle_despacho])
        REFERENCES dbo.[DetalleDespacho] ([id_detalle_despacho]);

    ALTER TABLE dbo.[MovimientoDevolucion] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoDevolucion_id_movimiento]
        FOREIGN KEY ([id_movimiento])
        REFERENCES dbo.[MovimientoInventario] ([id_movimiento]);

    ALTER TABLE dbo.[MovimientoDevolucion] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoDevolucion_id_detalle_devolucion]
        FOREIGN KEY ([id_detalle_devolucion])
        REFERENCES dbo.[DetalleDevolucion] ([id_detalle_devolucion]);

    ALTER TABLE dbo.[MovimientoInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoInspeccion_id_movimiento]
        FOREIGN KEY ([id_movimiento])
        REFERENCES dbo.[MovimientoInventario] ([id_movimiento]);

    ALTER TABLE dbo.[MovimientoInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoInspeccion_id_detalle_inspeccion]
        FOREIGN KEY ([id_detalle_inspeccion])
        REFERENCES dbo.[DetalleInspeccion] ([id_detalle_inspeccion]);

    ALTER TABLE dbo.[MovimientoRevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoRevisionMaterial_id_movimiento]
        FOREIGN KEY ([id_movimiento])
        REFERENCES dbo.[MovimientoInventario] ([id_movimiento]);

    ALTER TABLE dbo.[MovimientoRevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoRevisionMaterial_id_revision_material]
        FOREIGN KEY ([id_revision_material])
        REFERENCES dbo.[RevisionMaterial] ([id_revision_material]);

    ALTER TABLE dbo.[IncidenciaAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaAlquiler_id_detalle_alquiler]
        FOREIGN KEY ([id_detalle_alquiler])
        REFERENCES dbo.[DetalleAlquiler] ([id_detalle_alquiler]);

    ALTER TABLE dbo.[IncidenciaInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaInspeccion_id_incidencia]
        FOREIGN KEY ([id_incidencia])
        REFERENCES dbo.[IncidenciaAlquiler] ([id_incidencia]);

    ALTER TABLE dbo.[IncidenciaInspeccion] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaInspeccion_id_detalle_inspeccion]
        FOREIGN KEY ([id_detalle_inspeccion])
        REFERENCES dbo.[DetalleInspeccion] ([id_detalle_inspeccion]);

    ALTER TABLE dbo.[CargoIncidencia] WITH CHECK
        ADD CONSTRAINT [FK_CargoIncidencia_id_incidencia]
        FOREIGN KEY ([id_incidencia])
        REFERENCES dbo.[IncidenciaAlquiler] ([id_incidencia]);

    ALTER TABLE dbo.[CargoIncidencia] WITH CHECK
        ADD CONSTRAINT [FK_CargoIncidencia_id_cargo]
        FOREIGN KEY ([id_cargo])
        REFERENCES dbo.[CargoAlquiler] ([id_cargo]);

    ALTER TABLE dbo.[EmpleadoServicio] WITH CHECK
        ADD CONSTRAINT [FK_EmpleadoServicio_id_empleado]
        FOREIGN KEY ([id_empleado])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[EmpleadoServicio] WITH CHECK
        ADD CONSTRAINT [FK_EmpleadoServicio_id_recurso]
        FOREIGN KEY ([id_recurso])
        REFERENCES dbo.[Recurso] ([id_recurso]);

    ALTER TABLE dbo.[AsignacionPersonal] WITH CHECK
        ADD CONSTRAINT [FK_AsignacionPersonal_id_detalle_alquiler]
        FOREIGN KEY ([id_detalle_alquiler])
        REFERENCES dbo.[DetalleAlquiler] ([id_detalle_alquiler]);

    ALTER TABLE dbo.[AsignacionPersonal] WITH CHECK
        ADD CONSTRAINT [FK_AsignacionPersonal_id_empleado]
        FOREIGN KEY ([id_empleado])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[IndisponibilidadPersonal] WITH CHECK
        ADD CONSTRAINT [FK_IndisponibilidadPersonal_id_empleado]
        FOREIGN KEY ([id_empleado])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[RegistroServicioPersonal] WITH CHECK
        ADD CONSTRAINT [FK_RegistroServicioPersonal_id_asignacion]
        FOREIGN KEY ([id_asignacion])
        REFERENCES dbo.[AsignacionPersonal] ([id_asignacion]);

    ALTER TABLE dbo.[UsuarioRol] WITH CHECK
        ADD CONSTRAINT [FK_UsuarioRol_id_usuario]
        FOREIGN KEY ([id_usuario])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[UsuarioRol] WITH CHECK
        ADD CONSTRAINT [FK_UsuarioRol_id_rol]
        FOREIGN KEY ([id_rol])
        REFERENCES dbo.[Rol] ([id_rol]);

    ALTER TABLE dbo.[RevisionSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_RevisionSolicitud_id_solicitud]
        FOREIGN KEY ([id_solicitud])
        REFERENCES dbo.[Solicitud] ([id_solicitud]);

    ALTER TABLE dbo.[EvaluacionDisponibilidad] WITH CHECK
        ADD CONSTRAINT [FK_EvaluacionDisponibilidad_id_solicitud]
        FOREIGN KEY ([id_solicitud])
        REFERENCES dbo.[Solicitud] ([id_solicitud]);

    ALTER TABLE dbo.[DetalleEvaluacionDisponibilidad] WITH CHECK
        ADD CONSTRAINT [FK_DetalleEvaluacionDisponibilidad_id_evaluacion]
        FOREIGN KEY ([id_evaluacion])
        REFERENCES dbo.[EvaluacionDisponibilidad] ([id_evaluacion]);

    ALTER TABLE dbo.[DetalleEvaluacionDisponibilidad] WITH CHECK
        ADD CONSTRAINT [FK_DetalleEvaluacionDisponibilidad_id_detalle_solicitud]
        FOREIGN KEY ([id_detalle_solicitud])
        REFERENCES dbo.[DetalleSolicitud] ([id_detalle_solicitud]);

    ALTER TABLE dbo.[Usuario] WITH CHECK
        ADD CONSTRAINT [FK_Usuario_id_empleado]
        FOREIGN KEY ([id_empleado])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[RevisionSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_RevisionSolicitud_id_usuario_revisor]
        FOREIGN KEY ([id_usuario_revisor])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[EvaluacionDisponibilidad] WITH CHECK
        ADD CONSTRAINT [FK_EvaluacionDisponibilidad_id_usuario_evaluador]
        FOREIGN KEY ([id_usuario_evaluador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[CargoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_CargoAlquiler_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[AjusteEconomicoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_AjusteEconomicoAlquiler_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[AjusteSolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_AjusteSolicitudCambio_id_solicitud_cambio]
        FOREIGN KEY ([id_solicitud_cambio])
        REFERENCES dbo.[SolicitudCambio] ([id_solicitud_cambio]);

    ALTER TABLE dbo.[AjusteSolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_AjusteSolicitudCambio_id_ajuste]
        FOREIGN KEY ([id_ajuste])
        REFERENCES dbo.[AjusteEconomicoAlquiler] ([id_ajuste]);

    ALTER TABLE dbo.[Pago] WITH CHECK
        ADD CONSTRAINT [FK_Pago_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[Reembolso] WITH CHECK
        ADD CONSTRAINT [FK_Reembolso_id_alquiler]
        FOREIGN KEY ([id_alquiler])
        REFERENCES dbo.[Alquiler] ([id_alquiler]);

    ALTER TABLE dbo.[ActividadSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_ActividadSolicitud_id_solicitud]
        FOREIGN KEY ([id_solicitud])
        REFERENCES dbo.[Solicitud] ([id_solicitud]);

    ALTER TABLE dbo.[ActividadCliente] WITH CHECK
        ADD CONSTRAINT [FK_ActividadCliente_id_cliente]
        FOREIGN KEY ([id_cliente])
        REFERENCES dbo.[Cliente] ([id_cliente]);

    ALTER TABLE dbo.[ActividadSolicitud] WITH CHECK
        ADD CONSTRAINT [FK_ActividadSolicitud_id_actividad]
        FOREIGN KEY ([id_actividad])
        REFERENCES dbo.[ActividadSeguimiento] ([id_actividad]);

    ALTER TABLE dbo.[ActividadCliente] WITH CHECK
        ADD CONSTRAINT [FK_ActividadCliente_id_actividad]
        FOREIGN KEY ([id_actividad])
        REFERENCES dbo.[ActividadSeguimiento] ([id_actividad]);

    ALTER TABLE dbo.[ActividadSeguimiento] WITH CHECK
        ADD CONSTRAINT [FK_ActividadSeguimiento_id_empleado_responsable]
        FOREIGN KEY ([id_empleado_responsable])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[RevisionDocumento] WITH CHECK
        ADD CONSTRAINT [FK_RevisionDocumento_id_revision]
        FOREIGN KEY ([id_revision])
        REFERENCES dbo.[RevisionSolicitud] ([id_revision]);

    ALTER TABLE dbo.[RevisionDocumento] WITH CHECK
        ADD CONSTRAINT [FK_RevisionDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[DespachoDetalleDocumento] WITH CHECK
        ADD CONSTRAINT [FK_DespachoDetalleDocumento_id_detalle_despacho]
        FOREIGN KEY ([id_detalle_despacho])
        REFERENCES dbo.[DetalleDespacho] ([id_detalle_despacho]);

    ALTER TABLE dbo.[DespachoDetalleDocumento] WITH CHECK
        ADD CONSTRAINT [FK_DespachoDetalleDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[EntregaDocumento] WITH CHECK
        ADD CONSTRAINT [FK_EntregaDocumento_id_constancia]
        FOREIGN KEY ([id_constancia])
        REFERENCES dbo.[ConstanciaEntrega] ([id_constancia]);

    ALTER TABLE dbo.[EntregaDocumento] WITH CHECK
        ADD CONSTRAINT [FK_EntregaDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[InspeccionDetalleDocumento] WITH CHECK
        ADD CONSTRAINT [FK_InspeccionDetalleDocumento_id_detalle_inspeccion]
        FOREIGN KEY ([id_detalle_inspeccion])
        REFERENCES dbo.[DetalleInspeccion] ([id_detalle_inspeccion]);

    ALTER TABLE dbo.[InspeccionDetalleDocumento] WITH CHECK
        ADD CONSTRAINT [FK_InspeccionDetalleDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[RevisionMaterialDocumento] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterialDocumento_id_revision_material]
        FOREIGN KEY ([id_revision_material])
        REFERENCES dbo.[RevisionMaterial] ([id_revision_material]);

    ALTER TABLE dbo.[RevisionMaterialDocumento] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterialDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[IncidenciaDocumento] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaDocumento_id_incidencia]
        FOREIGN KEY ([id_incidencia])
        REFERENCES dbo.[IncidenciaAlquiler] ([id_incidencia]);

    ALTER TABLE dbo.[IncidenciaDocumento] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[PagoDocumento] WITH CHECK
        ADD CONSTRAINT [FK_PagoDocumento_id_pago]
        FOREIGN KEY ([id_pago])
        REFERENCES dbo.[Pago] ([id_pago]);

    ALTER TABLE dbo.[PagoDocumento] WITH CHECK
        ADD CONSTRAINT [FK_PagoDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[ReembolsoDocumento] WITH CHECK
        ADD CONSTRAINT [FK_ReembolsoDocumento_id_reembolso]
        FOREIGN KEY ([id_reembolso])
        REFERENCES dbo.[Reembolso] ([id_reembolso]);

    ALTER TABLE dbo.[ReembolsoDocumento] WITH CHECK
        ADD CONSTRAINT [FK_ReembolsoDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    ALTER TABLE dbo.[Cotizacion] WITH CHECK
        ADD CONSTRAINT [FK_Cotizacion_id_usuario_autorizador]
        FOREIGN KEY ([id_usuario_autorizador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Alquiler] WITH CHECK
        ADD CONSTRAINT [FK_Alquiler_id_usuario_aprobador]
        FOREIGN KEY ([id_usuario_aprobador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[SolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_SolicitudCambio_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[SolicitudCambio] WITH CHECK
        ADD CONSTRAINT [FK_SolicitudCambio_id_usuario_decisor]
        FOREIGN KEY ([id_usuario_decisor])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Despacho] WITH CHECK
        ADD CONSTRAINT [FK_Despacho_id_usuario_autorizador]
        FOREIGN KEY ([id_usuario_autorizador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Despacho] WITH CHECK
        ADD CONSTRAINT [FK_Despacho_id_empleado_entrega]
        FOREIGN KEY ([id_empleado_entrega])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[Devolucion] WITH CHECK
        ADD CONSTRAINT [FK_Devolucion_id_empleado_receptor]
        FOREIGN KEY ([id_empleado_receptor])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[Devolucion] WITH CHECK
        ADD CONSTRAINT [FK_Devolucion_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Inspeccion] WITH CHECK
        ADD CONSTRAINT [FK_Inspeccion_id_empleado_inspector]
        FOREIGN KEY ([id_empleado_inspector])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[Inspeccion] WITH CHECK
        ADD CONSTRAINT [FK_Inspeccion_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[MovimientoInventario] WITH CHECK
        ADD CONSTRAINT [FK_MovimientoInventario_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_empleado_revisor]
        FOREIGN KEY ([id_empleado_revisor])
        REFERENCES dbo.[Empleado] ([id_empleado]);

    ALTER TABLE dbo.[RevisionMaterial] WITH CHECK
        ADD CONSTRAINT [FK_RevisionMaterial_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[IncidenciaAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_IncidenciaAlquiler_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[CargoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_CargoAlquiler_id_usuario_autorizador]
        FOREIGN KEY ([id_usuario_autorizador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[CargoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_CargoAlquiler_id_usuario_anulacion]
        FOREIGN KEY ([id_usuario_anulacion])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[AsignacionPersonal] WITH CHECK
        ADD CONSTRAINT [FK_AsignacionPersonal_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[IndisponibilidadPersonal] WITH CHECK
        ADD CONSTRAINT [FK_IndisponibilidadPersonal_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[RegistroServicioPersonal] WITH CHECK
        ADD CONSTRAINT [FK_RegistroServicioPersonal_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[AjusteEconomicoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_AjusteEconomicoAlquiler_id_usuario_autorizador]
        FOREIGN KEY ([id_usuario_autorizador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[AjusteEconomicoAlquiler] WITH CHECK
        ADD CONSTRAINT [FK_AjusteEconomicoAlquiler_id_usuario_anulacion]
        FOREIGN KEY ([id_usuario_anulacion])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Pago] WITH CHECK
        ADD CONSTRAINT [FK_Pago_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Pago] WITH CHECK
        ADD CONSTRAINT [FK_Pago_id_usuario_anulacion]
        FOREIGN KEY ([id_usuario_anulacion])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Reembolso] WITH CHECK
        ADD CONSTRAINT [FK_Reembolso_id_usuario_autorizador]
        FOREIGN KEY ([id_usuario_autorizador])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Reembolso] WITH CHECK
        ADD CONSTRAINT [FK_Reembolso_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Reembolso] WITH CHECK
        ADD CONSTRAINT [FK_Reembolso_id_usuario_anulacion]
        FOREIGN KEY ([id_usuario_anulacion])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[ActividadSeguimiento] WITH CHECK
        ADD CONSTRAINT [FK_ActividadSeguimiento_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[Documento] WITH CHECK
        ADD CONSTRAINT [FK_Documento_id_usuario_registro]
        FOREIGN KEY ([id_usuario_registro])
        REFERENCES dbo.[Usuario] ([id_usuario]);

    ALTER TABLE dbo.[DevolucionDocumento] WITH CHECK
        ADD CONSTRAINT [FK_DevolucionDocumento_id_devolucion]
        FOREIGN KEY ([id_devolucion])
        REFERENCES dbo.[Devolucion] ([id_devolucion]);

    ALTER TABLE dbo.[DevolucionDocumento] WITH CHECK
        ADD CONSTRAINT [FK_DevolucionDocumento_id_documento]
        FOREIGN KEY ([id_documento])
        REFERENCES dbo.[Documento] ([id_documento]);

    COMMIT TRANSACTION;
    PRINT N'DDL BASE COMPLETADO';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
