# Manifiesto de la entrega de sustentacion

El paquete completo contiene:

- `Backup/Backup_DafelDB_Original.bak`: respaldo completo de `DafelDB`, validado
  con `RESTORE HEADERONLY`.
- `Consultas_SQL/`: doce consultas individuales y un ejecutor general.
- `migrations/`: scripts reproducibles de construccion y capa analitica.
- `tests/`: pruebas de integridad, operacion y Power BI.
- `PowerBI/`: dashboard general, dashboard de Consulta 09 y documentacion.
- `docs/`: contexto, modelo relacional y documentos tecnicos.
- `tools/`: utilidades de extraccion y validacion.
- `GUIA_SUSTENTACION.md`: orden recomendado para la exposicion.

La base principal es `DafelDB`. No se debe volver a ejecutar
`migrations/900_Promover_Validacion.sql` sobre una instalacion ya promovida.
