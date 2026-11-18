# DafelDB consolidada

Este directorio contiene la consolidación del modelo antiguo de 43 tablas y el modelo académico de 68 tablas.

## Estado instalado

- Base principal: `DafelDB`.
- Base anterior preservada: `DafelDB_Legacy_20261116`.
- Base de trabajo preservada: `DafelDB_Validacion`.
- Motor comprobado: SQL Server 2022 Express, compatibilidad 160.
- Modelo principal: 68 tablas, 129 FK, 5 vistas, 23 procedimientos y 84 triggers.
- Las FK y restricciones CHECK están habilitadas y son confiables.
- `DBCC CHECKDB` terminó sin errores.
- Capa Power BI instalada: esquema `bi`, dimensión de fechas, cuatro dimensiones
  descriptivas y doce vistas analíticas correspondientes al Excel de consultas.
- Datos BI ficticios: 8 empleados, 120 solicitudes nuevas y 94 alquileres nuevos.

## Respaldos

En la carpeta predeterminada de respaldos de SQL Server se encuentran:

- `DafelDB_PreConsolidacion_20261116_1436.bak`: versión anterior a los cambios.
- `DafelDB_Consolidada_20261116.bak`: versión consolidada, con checksum y restaurada para crear la base principal.

No eliminar la base legado ni los respaldos hasta terminar la sustentación y confirmar que no se necesita recuperar el modelo anterior.

## Orden de construcción utilizado

1. `000_Crear_Base_Validacion.sql`
2. `001_Modelo_Base_68_Tablas.sql`
3. `002_Dominios_Estados.sql`
4. `003_Indices.sql`
5. `004_Objetos_Programables.sql`
6. `005_Seguridad.sql`
7. `006_Clasificacion_Economica_Reportes.sql`
8. `007_Integridad_Operativa.sql`
9. `008_Ajustes_Finales.sql`
10. `009_Descripciones.sql`
11. Datos y pruebas de la carpeta `tests`.
12. `900_Promover_Validacion.sql`

El script `900` no es repetible: cambia nombres y restaura la base definitiva. No debe ejecutarse otra vez.

## Evidencia ejecutada

- Cálculo económico: total 490000, pagos 440000, saldo 50000.
- Entrega parcial: despachado 2, devuelto 1, pendiente 1.
- Pico de reservas no simultáneas: 4 y no 7.
- Dos evaluaciones conservadas sin duplicar la solicitud en el reporte 12.
- Rechazo de cruces de personal, devoluciones e inspecciones excesivas.
- Rechazo de despacho sin anticipo y reembolso superior a los pagos.
- Separación entre cierre operativo y financiero.
- Cancelación previa al despacho con liberación de reservas y reembolso autorizado.
- Pruebas de mínimo privilegio con usuarios `WITHOUT LOGIN`.

Los registros cargados son ficticios y están identificados con códigos `DAFEL-DEMO-*`.
La ampliación para Power BI usa códigos `DAFEL-BI-*`, `SOL-BI-*` y `ALQ-BI-*`.

La guía del informe, el tema y las medidas DAX están en [PowerBI](PowerBI/README.md).

Las doce consultas ejecutables para SQL Server Management Studio y el archivo
maestro de demostración están en [Consultas_SQL](Consultas_SQL/README.md).

El modelo editable corregido está en [docs/Modelo_Relacional_Dafel.drawio](docs/Modelo_Relacional_Dafel.drawio). El diccionario técnico real puede extraerse desde SQL Server con [tools/Extraer_Diccionario.sql](tools/Extraer_Diccionario.sql).

