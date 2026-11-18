# Dashboard individual - Consulta 09

## Objetivo

Este entregable desarrolla un dashboard independiente para el punto solicitado:

> Por periodo, alquiler, cliente y obra: sumar valores aprobados de equipos,
> personal y transporte; separar cargos adicionales, pagos recibidos y
> reembolsos. Recaudo neto = pagos recibidos - reembolsos efectuados, segun la
> fecha de cada movimiento.

El archivo principal es `DafelDB_Dashboard_Consulta09.pbix`. El dashboard general
del proyecto permanece en `DafelDB_Dashboard.pbix` y no fue reemplazado.

## Fuente SQL y grano

El PBIX usa exclusivamente la vista `bi.vw_09_ValoresRecaudosEventos`, creada por
`../migrations/012_Consulta09_Eventos.sql`.

El grano es **una fila por evento financiero**:

- `APROBACION`: fecha de confirmacion del alquiler.
- `CARGO_ADICIONAL`: fecha de autorizacion del cargo vigente.
- `PAGO`: fecha del pago vigente.
- `REEMBOLSO`: fecha efectiva del reembolso efectuado.

La vista evita duplicar los valores aprobados cuando un alquiler tiene varios
pagos o cargos.

## Contenido del dashboard

- Suma aprobada de equipos.
- Suma aprobada de personal.
- Suma aprobada de transporte.
- Cargos adicionales vigentes.
- Pagos recibidos vigentes.
- Reembolsos efectuados.
- Recaudo neto: pagos recibidos menos reembolsos efectuados.
- Tendencia mensual de pagos, reembolsos y recaudo neto por fecha de movimiento.
- Tabla de detalle por periodo, alquiler, cliente y obra con todos los importes.

Todos los objetos visuales se alimentan de la misma vista de eventos. La pagina
del informe se llama **Dashboard Consulta 09**.

## Validacion final

Validacion realizada contra `DafelDB` el 17 de noviembre de 2026:

- 303 eventos financieros.
- 96 alquileres.
- 12 clientes y 12 obras.
- Valores aprobados de equipos: $75.563.000.
- Valores aprobados de personal: $29.640.000.
- Valores aprobados de transporte: $4.005.000.
- Cargos adicionales vigentes: $720.000.
- Pagos recibidos vigentes: $109.798.000.
- Reembolsos efectuados: $0; no existen registros efectivos en la base actual.
- Recaudo neto: $109.798.000.
- Periodo disponible: noviembre de 2025 a noviembre de 2026.

No se inventaron movimientos ni reembolsos para completar el dashboard.

## Archivos

- `DafelDB_Dashboard_Consulta09.pbix`: dashboard editable de la Consulta 09.
- `Consulta09_ValoresRecaudos.sql`: consulta ejecutable en SQL Server.
- `Vista_previa_Dashboard_Consulta09.png`: evidencia visual del resultado.
- `../migrations/012_Consulta09_Eventos.sql`: definicion reproducible de la vista.
