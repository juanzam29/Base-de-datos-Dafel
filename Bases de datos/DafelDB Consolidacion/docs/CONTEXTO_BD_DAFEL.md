# Contexto de base de datos Dafel

Dafel alquila andamios, herramientas y servicios de personal. La base respalda solicitudes mixtas, evaluación de disponibilidad, cotizaciones versionadas, alquileres, reservas, asignaciones, despachos, devoluciones, inspecciones, incidencias, cargos, pagos, reembolsos, documentos, seguimiento y cierres independientes.

## Convenciones académicas pendientes de confirmación empresarial

- Anticipo inicial predeterminado del 100 % antes del primer despacho.
- Equipos cobrados por bloques iniciados de 24 horas.
- Personal cobrado por jornadas acordadas.
- El retorno no vuelve disponible el material hasta completar su inspección o revisión.
- Los daños conservan estimación, responsabilidad y cargo autorizado por separado.
- El cierre operativo y el financiero son independientes.

Estas reglas son convenciones del proyecto, no políticas empresariales confirmadas.

## Diseño vigente

- Equipos y personal comparten el catálogo `Recurso`, diferenciados por `naturaleza`.
- Las condiciones aceptadas se conservan en cotizaciones y solicitudes de cambio.
- El inventario se deriva de movimientos firmados por recurso, bodega y condición.
- Las reservas conservan versiones y su última versión determina el estado vigente.
- Despachos, devoluciones e inspecciones admiten cantidades parciales.
- Los conceptos económicos se clasifican para separar transporte, retrasos, daños y faltantes.
- Los documentos guardan referencia externa y pueden registrar tamaño y SHA-256; la base no almacena el archivo.
- La auditoría técnica no sustituye el historial funcional del negocio.

## Bases existentes

- `DafelDB`: versión consolidada principal.
- `DafelDB_Legacy_20261116`: modelo anterior completo, preservado para recuperación.
- `DafelDB_Validacion`: copia de validación usada antes de la promoción.

No ejecutar los scripts antiguos de `Dafel sprints` sobre la base consolidada: pertenecen al modelo legado y contienen referencias a `DaferDB`.

