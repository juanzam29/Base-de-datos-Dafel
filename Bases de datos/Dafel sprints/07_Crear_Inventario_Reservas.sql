USE DaferDB;
GO

-- 1. EXISTENCIAS POR BODEGA Y CONDICION

CREATE TABLE dbo.Inventario
(
    id_inventario INT IDENTITY(1,1) NOT NULL,
    id_recurso INT NOT NULL,
    id_bodega INT NOT NULL,
    id_condicion INT NOT NULL,
    cantidad INT NOT NULL
        CONSTRAINT DF_Inventario_cantidad DEFAULT 0,

    CONSTRAINT PK_Inventario
        PRIMARY KEY (id_inventario),

    CONSTRAINT FK_Inventario_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso(id_recurso),

    CONSTRAINT FK_Inventario_Bodega
        FOREIGN KEY (id_bodega)
        REFERENCES dbo.Bodega(id_bodega),

    CONSTRAINT FK_Inventario_Condicion
        FOREIGN KEY (id_condicion)
        REFERENCES dbo.CondicionMaterial(id_condicion),

    CONSTRAINT UQ_Inventario_ubicacion
        UNIQUE (id_recurso, id_bodega, id_condicion),

    CONSTRAINT CK_Inventario_cantidad
        CHECK (cantidad >= 0)
);
GO

-- 2. CABECERA DEL MOVIMIENTO

CREATE TABLE dbo.MovimientoInventario
(
    id_movimiento INT IDENTITY(1,1) NOT NULL,
    id_tipo_movimiento INT NOT NULL,
    id_usuario INT NOT NULL,

    fecha_movimiento DATETIME2(0) NOT NULL
        CONSTRAINT DF_MovimientoInventario_fecha
        DEFAULT SYSDATETIME(),

    referencia VARCHAR(50) NULL,
    observaciones NVARCHAR(1000) NULL,

    CONSTRAINT PK_MovimientoInventario
        PRIMARY KEY (id_movimiento),

    CONSTRAINT FK_MovimientoInventario_Tipo
        FOREIGN KEY (id_tipo_movimiento)
        REFERENCES dbo.TipoMovimiento(id_tipo_movimiento),

    CONSTRAINT FK_MovimientoInventario_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES dbo.Usuario(id_usuario)
);
GO

-- 3. DETALLE DE MOVIMIENTO

CREATE TABLE dbo.DetalleMovimientoInventario
(
    id_detalle_movimiento INT IDENTITY(1,1) NOT NULL,
    id_movimiento INT NOT NULL,
    numero_linea INT NOT NULL,
    id_recurso INT NOT NULL,

    id_bodega_origen INT NULL,
    id_condicion_origen INT NULL,

    id_bodega_destino INT NULL,
    id_condicion_destino INT NULL,

    cantidad INT NOT NULL,

    CONSTRAINT PK_DetalleMovimientoInventario
        PRIMARY KEY (id_detalle_movimiento),

    CONSTRAINT FK_DetalleMovimiento_Movimiento
        FOREIGN KEY (id_movimiento)
        REFERENCES dbo.MovimientoInventario(id_movimiento),

    CONSTRAINT FK_DetalleMovimiento_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso(id_recurso),

    CONSTRAINT FK_DetalleMovimiento_BodegaOrigen
        FOREIGN KEY (id_bodega_origen)
        REFERENCES dbo.Bodega(id_bodega),

    CONSTRAINT FK_DetalleMovimiento_BodegaDestino
        FOREIGN KEY (id_bodega_destino)
        REFERENCES dbo.Bodega(id_bodega),

    CONSTRAINT FK_DetalleMovimiento_CondicionOrigen
        FOREIGN KEY (id_condicion_origen)
        REFERENCES dbo.CondicionMaterial(id_condicion),

    CONSTRAINT FK_DetalleMovimiento_CondicionDestino
        FOREIGN KEY (id_condicion_destino)
        REFERENCES dbo.CondicionMaterial(id_condicion),

    CONSTRAINT UQ_DetalleMovimiento_linea
        UNIQUE (id_movimiento, numero_linea),

    CONSTRAINT CK_DetalleMovimiento_linea
        CHECK (numero_linea > 0),

    CONSTRAINT CK_DetalleMovimiento_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_DetalleMovimiento_origen
        CHECK (
            (id_bodega_origen IS NULL
             AND id_condicion_origen IS NULL)
            OR
            (id_bodega_origen IS NOT NULL
             AND id_condicion_origen IS NOT NULL)
        ),

    CONSTRAINT CK_DetalleMovimiento_destino
        CHECK (
            (id_bodega_destino IS NULL
             AND id_condicion_destino IS NULL)
            OR
            (id_bodega_destino IS NOT NULL
             AND id_condicion_destino IS NOT NULL)
        ),

    CONSTRAINT CK_DetalleMovimiento_extremos
        CHECK (
            id_bodega_origen IS NOT NULL
            OR id_bodega_destino IS NOT NULL
        ),

    CONSTRAINT CK_DetalleMovimiento_cambio
        CHECK (
            id_bodega_origen IS NULL
            OR id_bodega_destino IS NULL
            OR id_bodega_origen <> id_bodega_destino
            OR id_condicion_origen <> id_condicion_destino
        )
);
GO

-- 4. RESERVA DE RECURSOS

CREATE TABLE dbo.Reserva
(
    id_reserva INT IDENTITY(1,1) NOT NULL,
    id_version INT NOT NULL,

    fecha_creacion DATETIME2(0) NOT NULL
        CONSTRAINT DF_Reserva_fecha
        DEFAULT SYSDATETIME(),

    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Reserva_estado
        DEFAULT 'ACTIVA',

    CONSTRAINT PK_Reserva
        PRIMARY KEY (id_reserva),

    CONSTRAINT FK_Reserva_Version
        FOREIGN KEY (id_version)
        REFERENCES dbo.VersionCotizacion(id_version),

    CONSTRAINT UQ_Reserva_Version
        UNIQUE (id_version),

    CONSTRAINT CK_Reserva_estado
        CHECK (estado IN (
            'ACTIVA',
            'LIBERADA',
            'CONSUMIDA',
            'CANCELADA'
        ))
);
GO

-- 5. DETALLES DE LA RESERVA

CREATE TABLE dbo.DetalleReserva
(
    id_detalle_reserva INT IDENTITY(1,1) NOT NULL,
    id_reserva INT NOT NULL,
    id_detalle_cotizacion INT NOT NULL,
    id_recurso INT NOT NULL,

    cantidad INT NOT NULL,
    fecha_inicio DATETIME2(0) NOT NULL,
    fecha_fin DATETIME2(0) NOT NULL,

    CONSTRAINT PK_DetalleReserva
        PRIMARY KEY (id_detalle_reserva),

    CONSTRAINT FK_DetalleReserva_Reserva
        FOREIGN KEY (id_reserva)
        REFERENCES dbo.Reserva(id_reserva),

    CONSTRAINT FK_DetalleReserva_DetalleCotizacion
        FOREIGN KEY (id_detalle_cotizacion)
        REFERENCES dbo.DetalleCotizacion(id_detalle_cotizacion),

    CONSTRAINT FK_DetalleReserva_Recurso
        FOREIGN KEY (id_recurso)
        REFERENCES dbo.Recurso(id_recurso),

    CONSTRAINT UQ_DetalleReserva_Cotizacion
        UNIQUE (id_reserva, id_detalle_cotizacion),

    CONSTRAINT CK_DetalleReserva_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_DetalleReserva_periodo
        CHECK (fecha_fin > fecha_inicio)
);
GO

-- INDICES PARA CONSULTAS OPERATIVAS

CREATE INDEX IX_DetalleReserva_RecursoPeriodo
ON dbo.DetalleReserva
(id_recurso, fecha_inicio, fecha_fin)
INCLUDE (cantidad, id_reserva);
GO

CREATE INDEX IX_MovimientoInventario_Fecha
ON dbo.MovimientoInventario(fecha_movimiento);
GO

CREATE INDEX IX_DetalleMovimiento_Recurso
ON dbo.DetalleMovimientoInventario(id_recurso);
GO