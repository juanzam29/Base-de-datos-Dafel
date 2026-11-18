USE DaferDB;
GO

-- 1. ASIGNAR EMPLEADO A UN SERVICIO

CREATE OR ALTER PROCEDURE dbo.sp_AsignarPersonal
    @id_detalle_alquiler INT,
    @id_empleado INT,
    @fecha_inicio DATETIME2(0),
    @fecha_fin DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @bloqueo INT,
        @id_recurso INT,
        @cantidad INT,
        @inicio_contrato DATETIME2(0),
        @fin_contrato DATETIME2(0);

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_AsignacionesPersonal',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50501, 'No se obtuvo el bloqueo.', 1;

        IF @fecha_inicio IS NULL OR @fecha_fin IS NULL
           OR @fecha_fin <= @fecha_inicio
            THROW 50502, 'Periodo invalido.', 1;

        SELECT
            @id_recurso = da.id_recurso,
            @cantidad = da.cantidad,
            @inicio_contrato = da.fecha_inicio,
            @fin_contrato = da.fecha_fin
        FROM dbo.DetalleAlquiler da
        INNER JOIN dbo.Alquiler a
            ON a.id_alquiler = da.id_alquiler
        INNER JOIN dbo.Recurso r
            ON r.id_recurso = da.id_recurso
        WHERE da.id_detalle_alquiler = @id_detalle_alquiler
          AND r.naturaleza = 'PERSONAL'
          AND r.activo = 1
          AND a.estado IN ('PENDIENTE', 'EN_EJECUCION');

        IF @id_recurso IS NULL
            THROW 50503,
                'No es un servicio de personal valido.', 1;

        IF @fecha_inicio < @inicio_contrato
           OR @fecha_fin > @fin_contrato
            THROW 50504,
                'Periodo fuera del contrato.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Empleado e
            INNER JOIN dbo.EmpleadoServicio es
                ON es.id_empleado = e.id_empleado
            WHERE e.id_empleado = @id_empleado
              AND e.activo = 1
              AND es.id_recurso = @id_recurso
        )
            THROW 50505,
                'Empleado no habilitado para el servicio.', 1;

        -- Evitar asignaciones superpuestas del empleado.

        IF EXISTS (
            SELECT 1
            FROM dbo.AsignacionPersonal ap
            WHERE ap.id_empleado = @id_empleado
              AND ap.estado <> 'CANCELADA'
              AND ap.fecha_inicio < @fecha_fin
              AND ap.fecha_fin > @fecha_inicio
        )
            THROW 50506,
                'Empleado ocupado durante el periodo.', 1;

        -- Verificar cantidad maxima de personas
        -- simultaneas por detalle de contrato.

        IF EXISTS (
            SELECT 1
            FROM (
                SELECT @fecha_inicio AS instante
                UNION
                SELECT ap.fecha_inicio
                FROM dbo.AsignacionPersonal ap
                WHERE ap.id_detalle_alquiler =
                      @id_detalle_alquiler
                  AND ap.estado <> 'CANCELADA'
                  AND ap.fecha_inicio < @fecha_fin
                  AND ap.fecha_fin > @fecha_inicio
            ) t
            CROSS APPLY (
                SELECT COUNT_BIG(*) AS ocupadas
                FROM dbo.AsignacionPersonal ap
                WHERE ap.id_detalle_alquiler =
                      @id_detalle_alquiler
                  AND ap.estado <> 'CANCELADA'
                  AND ap.fecha_inicio <= t.instante
                  AND ap.fecha_fin > t.instante
            ) c
            WHERE c.ocupadas >= @cantidad
        )
            THROW 50507,
                'Se supera la cantidad de personal contratado.', 1;

        INSERT INTO dbo.AsignacionPersonal
        (
            id_detalle_alquiler,
            id_empleado,
            fecha_inicio,
            fecha_fin,
            estado
        )
        VALUES
        (
            @id_detalle_alquiler,
            @id_empleado,
            @fecha_inicio,
            @fecha_fin,
            'PROGRAMADA'
        );

        DECLARE @id_asignacion INT =
            CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        SELECT
            @id_asignacion AS id_asignacion,
            'PROGRAMADA' AS estado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 2. REGISTRAR PERIODO REAL DE TRABAJO

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarServicio
    @id_asignacion INT,
    @fecha_inicio_real DATETIME2(0),
    @fecha_fin_real DATETIME2(0),
    @observaciones NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @bloqueo INT,
        @inicio DATETIME2(0),
        @fin DATETIME2(0),
        @estado VARCHAR(20);

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC @bloqueo = sys.sp_getapplock
            @Resource = 'DaferDB_RegistrosServicio',
            @LockMode = 'Exclusive',
            @LockOwner = 'Transaction',
            @LockTimeout = 15000;

        IF @bloqueo < 0
            THROW 50510, 'No se obtuvo el bloqueo.', 1;

        IF @fecha_inicio_real IS NULL
           OR @fecha_fin_real IS NULL
           OR @fecha_fin_real <= @fecha_inicio_real
            THROW 50511, 'Periodo real invalido.', 1;

        SELECT
            @inicio = ap.fecha_inicio,
            @fin = ap.fecha_fin,
            @estado = ap.estado
        FROM dbo.AsignacionPersonal ap WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.DetalleAlquiler da
            ON da.id_detalle_alquiler = ap.id_detalle_alquiler
        INNER JOIN dbo.Alquiler a
            ON a.id_alquiler = da.id_alquiler
        WHERE ap.id_asignacion = @id_asignacion
          AND a.estado = 'EN_EJECUCION';

        IF @estado IS NULL OR @estado = 'CANCELADA'
            THROW 50512,
                'Asignacion no valida para registrar trabajo.', 1;

        IF @fecha_inicio_real < @inicio
           OR @fecha_fin_real > @fin
            THROW 50513,
                'Registro fuera del periodo asignado.', 1;

        IF EXISTS (
            SELECT 1
            FROM dbo.RegistroServicio rs
            WHERE rs.id_asignacion = @id_asignacion
              AND rs.estado <> 'ANULADO'
              AND rs.fecha_inicio_real < @fecha_fin_real
              AND rs.fecha_fin_real > @fecha_inicio_real
        )
            THROW 50514,
                'Existe un registro de trabajo superpuesto.', 1;

        INSERT INTO dbo.RegistroServicio
        (
            id_asignacion,
            fecha_inicio_real,
            fecha_fin_real,
            estado,
            observaciones
        )
        VALUES
        (
            @id_asignacion,
            @fecha_inicio_real,
            @fecha_fin_real,
            'REGISTRADO',
            @observaciones
        );

        DECLARE @id_registro INT =
            CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        SELECT
            @id_registro AS id_registro_servicio,
            'REGISTRADO' AS estado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO