# Consultas SQL para sustentacion

Esta carpeta contiene las doce consultas analiticas de DafelDB listas para
ejecutarse en SQL Server Management Studio.

## Uso rapido

1. Conectarse a `DESKTOP-5K1DA26\SQLEXPRESS`.
2. Abrir el archivo deseado.
3. Confirmar que la base activa sea `DafelDB`.
4. Ejecutar con `F5`.

`00_Ejecutar_Todas_Las_Consultas.sql` abre un conjunto de resultados por cada
consulta. Los archivos `01` a `12` incluyen una salida detallada y otra resumida
para explicar el resultado durante la sustentacion.

Las consultas consumen las vistas del esquema `bi`; no modifican datos.

| Archivo | Vista principal | Tema |
|---|---|---|
| 01 | `bi.vw_01_Inventario` | Inventario disponible |
| 02 | `bi.vw_02_DisponibilidadFutura` | Compromisos futuros |
| 03 | `bi.vw_03_Cotizaciones` | Cotizaciones y conversion |
| 04 | `bi.vw_04_AlquileresActivos` | Alquileres activos y retrasos |
| 05 | `bi.vw_05_DespachosDevoluciones` | Despachos y devoluciones |
| 06 | `bi.vw_06_UtilizacionEquipos` | Utilizacion de equipos |
| 07 | `bi.vw_07_Liquidacion` | Liquidacion de alquileres |
| 08 | `bi.vw_08_PagosSaldos` | Pagos, saldos y cartera |
| 09 | `bi.vw_09_ValoresRecaudosEventos` | Valores y recaudos por evento |
| 10 | `bi.vw_10_Incidencias` | Incidencias y cargos |
| 11 | `bi.vw_11_Inspecciones` | Inspecciones de material |
| 12 | `bi.vw_12_DemandaNoAtendida` | Demanda no atendida |

