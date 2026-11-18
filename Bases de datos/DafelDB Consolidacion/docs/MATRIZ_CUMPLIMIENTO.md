# Matriz de cumplimiento de reportes

| No. | Requisito | Objeto principal | Evidencia ejecutada | Estado |
|---:|---|---|---|---|
| 1 | Inventario por recurso, bodega y condición | `reporte.usp_01_Inventario`, `v_SaldoFisico` | Apto 8, dañado 1, en cliente 1 y reserva pendiente 1 | Verificado con caso ficticio |
| 2 | Disponibilidad futura y conflictos | `reporte.usp_02_DisponibilidadFutura`, `v_ReservaVigente` | Reservas no simultáneas 3 y 4 producen pico 4; faltante calculado 1 | Verificado con caso ficticio |
| 3 | Cotizaciones y conversión | `reporte.usp_03_Cotizaciones` | Duración 3 bloques, recursos 410000, transporte 30000 y total 440000 | Verificado con caso ficticio |
| 4 | Activos, vencidos y cambios | `reporte.usp_04_ActivosVencidos` | Retorno parcial y bloque iniciado de retraso visibles | Ejecución verificada |
| 5 | Despachos y devoluciones por obra | `reporte.usp_05_DespachosDevoluciones`, `v_EntregaSaldo` | Contratado 3, despachado 2, devuelto 1, pendiente 1 | Verificado con aserción |
| 6 | Utilización | `reporte.usp_06_Utilizacion` | Equipos en uso, capacidad apta y condiciones bloqueadas separados | Ejecución verificada; requiere más periodos reales para análisis estadístico |
| 7 | Liquidación y cargos | `reporte.usp_07_Liquidacion`, `v_Liquidacion` | Equipos, personal, transporte, daño y ajuste separados; total 490000 | Verificado con aserción |
| 8 | Pagos, anticipos y saldos | `reporte.usp_08_PagosSaldos` | Anticipo 440000 y saldo 50000 | Verificado con aserción |
| 9 | Valores y recaudos | `reporte.usp_09_ValoresRecaudos` | Desglose por alquiler, cliente y obra; recaudo neto 440000 | Verificado con caso ficticio |
| 10 | Daños, pérdidas y diferencias | `reporte.usp_10_Incidencias` | Estimación 35000 y cargo autorizado 30000 separados | Verificado con caso ficticio |
| 11 | Inspecciones y materiales bloqueados | `reporte.usp_11_InspeccionesBloqueos` | Unidad dañada permanece no disponible y trazada a la devolución | Verificado con caso ficticio |
| 12 | Solicitudes parciales o no atendidas | `reporte.usp_12_DemandaNoAtendida` | Dos evaluaciones históricas generan una sola solicitud con faltante 3 | Verificado con aserción |

“Ejecución verificada” significa que el procedimiento terminó sin error y produjo la estructura esperada. No sustituye pruebas con volumen real ni mediciones de rendimiento.

