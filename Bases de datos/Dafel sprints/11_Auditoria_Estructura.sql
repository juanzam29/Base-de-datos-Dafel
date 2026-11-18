USE DaferDB;
GO

-- RESUMEN GENERAL DE LA BASE DE DATOS

SELECT
    (SELECT COUNT(*) FROM sys.tables
     WHERE is_ms_shipped = 0) AS total_tablas,

    (SELECT COUNT(*) FROM sys.foreign_keys
     WHERE is_ms_shipped = 0) AS total_claves_foraneas,

    (SELECT COUNT(*) FROM sys.key_constraints
     WHERE type = 'PK') AS total_claves_primarias,

    (SELECT COUNT(*) FROM sys.check_constraints
     WHERE is_ms_shipped = 0) AS total_restricciones_check;
GO



USE DaferDB;
GO

DECLARE @Esperadas TABLE
(
    nombre SYSNAME PRIMARY KEY
);

INSERT INTO @Esperadas(nombre)
VALUES
('Cliente'),
('Obra'),
('Categoria'),
('Recurso'),
('UnidadCobro'),
('TarifaRecurso'),
('Bodega'),
('CondicionMaterial'),
('TipoMovimiento'),
('Empleado'),
('Usuario'),
('Rol'),
('UsuarioRol'),
('EmpleadoServicio'),
('Solicitud'),
('DetalleSolicitud'),
('VerificacionSolicitud'),
('Cotizacion'),
('VersionCotizacion'),
('DetalleCotizacion'),
('Inventario'),
('MovimientoInventario'),
('DetalleMovimientoInventario'),
('Reserva'),
('DetalleReserva'),
('Alquiler'),
('DetalleAlquiler'),
('Despacho'),
('DetalleDespacho'),
('Entrega'),
('DetalleEntrega'),
('Devolucion'),
('DetalleDevolucion'),
('InspeccionDevolucion'),
('DetalleInspeccion'),
('CierreAlquiler'),
('AsignacionPersonal'),
('RegistroServicio'),
('TipoNovedadServicio'),
('NovedadServicio');

SELECT
    e.nombre AS tabla_faltante
FROM @Esperadas e
WHERE NOT EXISTS
(
    SELECT 1
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name = 'dbo'
      AND t.name = e.nombre
)
ORDER BY e.nombre;

SELECT
    COUNT(*) AS tablas_esperadas,
    SUM(CASE WHEN t.object_id IS NOT NULL
        THEN 1 ELSE 0 END) AS tablas_encontradas
FROM @Esperadas e
LEFT JOIN sys.tables t
    ON t.name = e.nombre
   AND t.schema_id = SCHEMA_ID('dbo');
GO



USE DaferDB;
GO

SELECT
    OBJECT_SCHEMA_NAME(parent_object_id) AS esquema,
    OBJECT_NAME(parent_object_id) AS tabla,
    name AS restriccion,
    is_disabled AS deshabilitada,
    is_not_trusted AS no_confiable
FROM sys.foreign_keys
WHERE is_disabled = 1
   OR is_not_trusted = 1
ORDER BY tabla, restriccion;
GO




USE DaferDB;
GO

SELECT
    OBJECT_NAME(parent_object_id) AS tabla,
    name AS restriccion,
    is_disabled AS deshabilitada,
    is_not_trusted AS no_confiable
FROM sys.check_constraints
WHERE is_disabled = 1
   OR is_not_trusted = 1
ORDER BY tabla, restriccion;
GO




USE DaferDB;
GO

SELECT
    OBJECT_NAME(parent_object_id) AS tabla,
    name AS restriccion,
    is_disabled AS deshabilitada,
    is_not_trusted AS no_confiable
FROM sys.check_constraints
WHERE is_disabled = 1
   OR is_not_trusted = 1
ORDER BY tabla, restriccion;
GO

