
USE DaferDB;
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- CLIENTE DE PRUEBA
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Cliente
        WHERE nit = 'PRUEBA-001'
    )
    BEGIN
        INSERT INTO dbo.Cliente
            (nit, razon_social, telefono, correo)
        VALUES
            ('PRUEBA-001',
             N'Constructora de Prueba',
             '3000000000',
             'prueba@example.com');
    END;

    -- OBRA DE PRUEBA
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Obra
        WHERE nombre = N'Obra Prueba Dafer'
          AND direccion = N'Direccion de prueba'
          AND ciudad = N'Bogota'
    )
    BEGIN
        INSERT INTO dbo.Obra
            (nombre, direccion, ciudad)
        VALUES
            (N'Obra Prueba Dafer',
             N'Direccion de prueba',
             N'Bogota');
    END;

    -- CATEGORIA
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Categoria
        WHERE nombre = N'Andamios - Prueba'
    )
    BEGIN
        INSERT INTO dbo.Categoria
            (nombre, descripcion)
        VALUES
            (N'Andamios - Prueba',
             N'Categoria para pruebas de DaferDB');
    END;

    DECLARE @categoria INT;

    SELECT @categoria = id_categoria
    FROM dbo.Categoria
    WHERE nombre = N'Andamios - Prueba';

    -- RECURSO
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Recurso
        WHERE codigo = 'AND-TEST-001'
    )
    BEGIN
        INSERT INTO dbo.Recurso
            (id_categoria, codigo, nombre, naturaleza)
        VALUES
            (@categoria,
             'AND-TEST-001',
             N'Andamio de prueba',
             'EQUIPO');
    END;

    -- BODEGA
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Bodega
        WHERE nombre = N'Bodega Prueba Dafer'
          AND direccion = N'Direccion de prueba'
    )
    BEGIN
        INSERT INTO dbo.Bodega
            (nombre, direccion)
        VALUES
            (N'Bodega Prueba Dafer',
             N'Direccion de prueba');
    END;

    -- CONDICION DEL MATERIAL
    IF NOT EXISTS (
        SELECT 1 FROM dbo.CondicionMaterial
        WHERE nombre = N'APTO - PRUEBA'
    )
    BEGIN
        INSERT INTO dbo.CondicionMaterial
            (nombre, permite_despacho)
        VALUES
            (N'APTO - PRUEBA', 1);
    END;

    -- UNIDAD DE COBRO
    IF NOT EXISTS (
        SELECT 1 FROM dbo.UnidadCobro
        WHERE nombre = N'24 HORAS - PRUEBA'
    )
    BEGIN
        INSERT INTO dbo.UnidadCobro
            (nombre, descripcion)
        VALUES
            (N'24 HORAS - PRUEBA',
             N'Bloque de 24 horas para pruebas');
    END;

    COMMIT TRANSACTION;

    SELECT 'DATOS BASE CARGADOS' AS resultado;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
