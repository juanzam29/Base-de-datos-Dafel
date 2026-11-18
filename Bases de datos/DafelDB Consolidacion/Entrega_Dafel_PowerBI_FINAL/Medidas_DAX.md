# Medidas DAX del modelo Dafel

Las siguientes 28 medidas ya se encuentran creadas en la tabla `Medidas` del
archivo `DafelDB_Dashboard.pbix`. Estan organizadas en las carpetas Comercial,
Composicion, Finanzas, Inventario, Operacion y Calidad.

## Indicadores principales

```DAX
Valor vigente =
SUM ( 'bi vw_08_PagosSaldos'[total_vigente] )

Recaudo neto =
SUM ( 'bi vw_08_PagosSaldos'[pagos_netos] )

Pagos recibidos =
SUM ( 'bi vw_08_PagosSaldos'[pagos_recibidos] )

Saldo pendiente =
SUM ( 'bi vw_08_PagosSaldos'[saldo_pendiente] )

Anticipos =
SUM ( 'bi vw_08_PagosSaldos'[anticipos] )

Reembolsos efectivos =
SUM ( 'bi vw_08_PagosSaldos'[reembolsos_efectivos] )

Cotizaciones =
DISTINCTCOUNT ( 'bi vw_03_Cotizaciones'[id_cotizacion] )

Cotizaciones convertidas =
CALCULATE (
    DISTINCTCOUNT ( 'bi vw_03_Cotizaciones'[id_cotizacion] ),
    'bi vw_03_Cotizaciones'[convertida] = TRUE ()
)

Conversion comercial % =
DIVIDE ( [Cotizaciones convertidas], [Cotizaciones], 0 )

Valor propuestas =
SUM ( 'bi vw_03_Cotizaciones'[valor_propuesta] )

Inventario fisico =
SUM ( 'bi vw_01_Inventario'[cantidad_fisica] )

Inventario apto =
SUM ( 'bi vw_01_Inventario'[apto_en_bodega] )

Inventario bloqueado =
SUM ( 'bi vw_01_Inventario'[no_apto_en_bodega] )

Inventario disponible =
SUM ( 'bi vw_01_Inventario'[disponible_estimado] )

Faltante solicitado =
CALCULATE (
    SUM ( 'bi vw_12_DemandaNoAtendida'[faltante] ),
    'bi vw_12_DemandaNoAtendida'[es_ultima_evaluacion] = TRUE ()
)

Utilizacion unidades-dia =
SUM ( 'bi vw_06_UtilizacionEquipos'[unidades_dia_alquiladas] )

Alquileres =
DISTINCTCOUNT ( 'bi vw_07_Liquidacion'[id_alquiler] )

Alquileres abiertos =
CALCULATE (
    DISTINCTCOUNT ( 'bi vw_04_AlquileresActivos'[id_alquiler] ),
    NOT ( 'bi vw_04_AlquileresActivos'[estado_operativo] IN { "CERRADO", "CANCELADO" } )
)

Despachado =
SUM ( 'bi vw_05_DespachosDevoluciones'[despachada] )

Devuelto =
SUM ( 'bi vw_05_DespachosDevoluciones'[devuelta] )

Pendiente de devolucion =
SUM ( 'bi vw_05_DespachosDevoluciones'[pendiente_devolucion] )

Incidencias =
DISTINCTCOUNT ( 'bi vw_10_Incidencias'[id_incidencia] )

Costo estimado incidencias =
SUM ( 'bi vw_10_Incidencias'[costo_estimado] )

Cargos autorizados =
SUM ( 'bi vw_10_Incidencias'[cargo_autorizado] )

Valor equipos =
SUM ( 'bi vw_07_Liquidacion'[equipos] )

Valor personal =
SUM ( 'bi vw_07_Liquidacion'[personal] )

Valor transporte =
SUM ( 'bi vw_07_Liquidacion'[transporte] )

Valor cargos adicionales =
SUM ( 'bi vw_07_Liquidacion'[cargos_adicionales] )
```

## Valores de control

- Valor vigente: 111.328.000.
- Recaudo neto: 109.798.000.
- Saldo pendiente: 1.705.000.
- Cotizaciones: 112.
- Cotizaciones convertidas: 96.
- Conversion: 85,71 %.
- Inventario fisico: 466.
- Inventario bloqueado: 10.
- Alquileres: 96.
- Alquileres abiertos: 2.
- Incidencias: 18.
- Faltante solicitado: 13.
