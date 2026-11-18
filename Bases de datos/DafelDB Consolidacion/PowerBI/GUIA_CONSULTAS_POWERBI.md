# Guia de las consultas en Power BI

El informe usa exclusivamente la capa analitica `bi` de `DafelDB`. Cada vista
corresponde a una consulta del archivo Excel y tiene una representacion visual
dentro de `DafelDB_Dashboard.pbix`.

## Pagina: Inventario y disponibilidad

### Consulta 01 - Inventario

- Vista: `bi.vw_01_Inventario`.
- Visual: disponible estimado agrupado por categoria.
- Lectura: muestra cuanto material puede comprometerse despues de descontar lo
  no apto, lo reservado y lo que permanece en clientes.

### Consulta 02 - Disponibilidad futura

- Vista: `bi.vw_02_DisponibilidadFutura`.
- Visual: cantidad despachada por codigo de recurso.
- Lectura: permite comparar los compromisos futuros con lo que ya fue entregado
  y detectar recursos que requieren planeacion adicional.

### Consulta 06 - Utilizacion de equipos

- Vista: `bi.vw_06_UtilizacionEquipos`.
- Visual: unidades-dia alquiladas por categoria.
- Lectura: mide la intensidad de uso combinando cantidad despachada y duracion
  del alquiler.

### Consulta 11 - Inspecciones

- Vista: `bi.vw_11_Inspecciones`.
- Visual: cantidad recibida por condicion resultante.
- Lectura: separa el material apto del danado despues de la recepcion e
  inspeccion.

### Consulta 12 - Demanda no atendida

- Vista: `bi.vw_12_DemandaNoAtendida`.
- Visual: cantidad faltante por codigo de recurso.
- Lectura: identifica los equipos que impiden atender completamente una
  solicitud.

## Pagina: Comercial y operaciones

### Consulta 03 - Cotizaciones

- Vista: `bi.vw_03_Cotizaciones`.
- Visual: valor propuesto agrupado por estado de la cotizacion.
- Lectura: compara el valor comercial aceptado, rechazado o todavia pendiente.

### Consulta 04 - Alquileres activos

- Vista: `bi.vw_04_AlquileresActivos`.
- Visual: dias de retraso por estado operativo.
- Lectura: evidencia alquileres vencidos o pendientes de devolucion.

### Consulta 05 - Despachos y devoluciones

- Vista: `bi.vw_05_DespachosDevoluciones`.
- Visual: pendiente de despacho por estado operativo y obra.
- Lectura: permite localizar cantidades contratadas que aun no han salido de
  bodega y relacionarlas con la obra responsable.

### Consulta 10 - Incidencias

- Vista: `bi.vw_10_Incidencias`.
- Visual: cantidad afectada agrupada por estado de la incidencia.
- Lectura: resume el impacto material de incidencias autorizadas, pendientes o
  resueltas.

## Pagina: Liquidacion y recaudo

### Consulta 07 - Liquidacion

- Vista: `bi.vw_07_Liquidacion`.
- Visual: valor vigente agrupado por estado operativo.
- Lectura: consolida conceptos cotizados, cargos adicionales, ajustes, pagos y
  reembolsos para determinar el valor financiero del alquiler.

### Consulta 08 - Pagos y saldos

- Vista: `bi.vw_08_PagosSaldos`.
- Visual: saldo pendiente agrupado por cliente.
- Lectura: prioriza los clientes con mayor cartera y permite revisar cada
  alquiler en la tabla del resumen gerencial.

### Consulta 09 - Valores y recaudos

- Vista: `bi.vw_09_ValoresRecaudos`.
- Visual: valor vigente y recaudo neto por mes de confirmacion.
- Lectura: compara lo facturable con el efectivo realmente recaudado y revela
  diferencias mensuales.

## Dashboard principal

`Resumen gerencial` integra filtros por anio, mes, cliente y ciudad; cuatro
indicadores; comparaciones por mes y cliente; distribucion por estado; y una
tabla de alquileres. Como el grupo tiene un solo integrante, esta pagina cumple
el requisito de un dashboard por integrante.
