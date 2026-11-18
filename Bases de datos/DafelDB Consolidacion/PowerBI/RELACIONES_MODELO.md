# Relaciones del modelo Power BI de Dafel

Fecha de validacion: 2026-11-16

## Estado final

- Fuente: `DESKTOP-5K1DA26\SQLEXPRESS`, base `DafelDB`.
- Tablas importadas: 17.
- Tabla calculada de indicadores: `Medidas`.
- Tablas totales del modelo: 18.
- Relaciones activas: 41.
- Relaciones inactivas: 0.
- Cardinalidad: 41 relaciones `*:1`.
- Direccion de filtro: 41 relaciones unidireccionales.
- Relaciones bidireccionales: 0.
- Relaciones detectadas automaticamente: 0.
- Calendarios locales automaticos: 0.

## Esquema estrella

Las tablas de consulta se conectan exclusivamente con las dimensiones. No
existen relaciones directas entre tablas de hechos.

| Dimension | Relaciones |
|---|---:|
| `bi DimFecha` | 12 |
| `bi vw_DimCliente` | 10 |
| `bi vw_DimObra` | 10 |
| `bi vw_DimRecurso` | 8 |
| `bi vw_DimEmpleado` | 1 |

## Criterios aplicados

- El lado `1` corresponde siempre a una dimension.
- El lado `*` corresponde siempre a una vista de consulta.
- Todos los filtros se propagan desde la dimension hacia la consulta.
- `bi DimFecha` es el unico calendario utilizado por el modelo.
- Las consultas con fecha y hora disponen de `FechaInforme` para relacionarse
  con `bi DimFecha[fecha]`.
- Se eliminaron las relaciones automaticas entre inventario, alquileres,
  liquidacion, pagos y las demas tablas de consulta.

## Pruebas de lectura

- Cotizaciones: 112.
- Pagos y saldos: 96.
- Valores y recaudos: 96.
- Cotizaciones de 2026 filtradas desde `bi DimFecha`: 92.
- Clientes propagados a cotizaciones: 12.
- Obras propagadas a pagos: 12.

Todos los objetos del modelo quedaron en estado `Ready`.
