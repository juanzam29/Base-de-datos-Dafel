# Registro de cambios

## 2026-11-16 — Preparación para Power BI

- Se conservaron ocho empleados: Daniel Palacios, Patricia y seis nombres ficticios.
- Se agregaron recursos, clientes, obras y 120 solicitudes de demostración.
- Se generaron 94 alquileres adicionales con reservas, pagos, despachos,
  devoluciones, inspecciones, ajustes e incidencias relacionados.
- Se creó el esquema `bi` con una dimensión de fechas, cuatro dimensiones
  descriptivas y doce vistas listas para importar en Power BI.
- Se creó el rol de solo lectura `dafel_powerbi` y un usuario de prueba sin login.
- Se agregaron tema, medidas DAX, especificación visual y guía de conexión.

## 2026-11-16 — Consolidación inicial

- Se creó y verificó un respaldo con checksum antes de modificar la instalación.
- Se construyó un modelo consolidado de 68 tablas y 129 relaciones.
- Se preservó la base anterior como `DafelDB_Legacy_20261116`.
- Se restauró la versión aprobada como `DafelDB`, con archivos lógicos y físicos corregidos.
- Se sustituyeron identificadores técnicos nuevos `Dafer` por `Dafel`.
- Se incorporaron dominios de estado, índices y 443 descripciones técnicas.
- Se instalaron 5 vistas, 12 reportes y 11 procedimientos operativos.
- Se agregaron controles concurrentes de reservas y asignaciones.
- Se agregaron límites acumulados de despacho, devolución e inspección.
- Se sincronizaron despacho, devolución e inspección con movimientos físicos.
- Se exigió el anticipo configurado antes de autorizar despachos.
- Se limitaron reembolsos a pagos vigentes.
- Se implementaron cierres operativo y financiero independientes.
- Se implementó cancelación anterior al despacho con liberación de reservas.
- Se separaron transporte, retrasos, daños, faltantes y anticipos mediante dominios estructurados.
- Se crearon roles `dafel_reportes`, `dafel_ventas`, `dafel_auditoria` y `dafel_sin_acceso`.
- Se ejecutaron pruebas funcionales, negativas, de permisos y `DBCC CHECKDB`.

## Pendientes no bloqueantes

- Confirmar con Dafel las políticas académicas de anticipo, redondeo, cancelación y retrasos.
- Medir planes e índices con un volumen representativo de datos.
- Conectar la gestión de documentos con almacenamiento real de archivos.
- Definir estrategia de logins para la aplicación cuando se implemente Spring Boot.
- Retirar la base legado únicamente después de terminar la sustentación y el periodo de recuperación acordado.

