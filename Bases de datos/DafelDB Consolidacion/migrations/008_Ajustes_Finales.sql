USE [DafelDB_Validacion];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id=OBJECT_ID(N'dbo.Usuario')
      AND name=N'CK_Usuario_hash_formato'
)
    ALTER TABLE dbo.Usuario WITH CHECK
    ADD CONSTRAINT CK_Usuario_hash_formato
    CHECK
    (
        LEN(hash_contrasena)=64
        AND hash_contrasena NOT LIKE '%[^0-9A-Fa-f]%'
    );
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Pago') AND name=N'IX_Pago_AlquilerEstadoTipo')
    CREATE INDEX IX_Pago_AlquilerEstadoTipo
        ON dbo.Pago(id_alquiler,estado,tipo_pago)
        INCLUDE(fecha_pago,importe);
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.CargoAlquiler') AND name=N'IX_CargoAlquiler_AlquilerEstadoTipo')
    CREATE INDEX IX_CargoAlquiler_AlquilerEstadoTipo
        ON dbo.CargoAlquiler(id_alquiler,estado,tipo_cargo)
        INCLUDE(fecha_autorizacion,importe);
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.ConceptoCotizacion') AND name=N'IX_ConceptoCotizacion_CotizacionTipo')
    CREATE INDEX IX_ConceptoCotizacion_CotizacionTipo
        ON dbo.ConceptoCotizacion(id_cotizacion,tipo_concepto)
        INCLUDE(cantidad,valor_unitario);
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Reembolso') AND name=N'IX_Reembolso_AlquilerEstado')
    CREATE INDEX IX_Reembolso_AlquilerEstado
        ON dbo.Reembolso(id_alquiler,estado)
        INCLUDE(fecha_autorizacion,fecha_efectiva,importe);
GO

PRINT N'AJUSTES FINALES COMPLETADOS';
GO
