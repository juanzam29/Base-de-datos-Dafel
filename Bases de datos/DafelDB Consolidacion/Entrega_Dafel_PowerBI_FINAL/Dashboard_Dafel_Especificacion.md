# Especificacion del dashboard Dafel

## Lienzo

- Formato: 16:9, 1280 x 720.
- Fondo: `#F5F7FA`.
- Encabezado: azul `#17324D`, titulo blanco y acento dorado `#F2A900`.
- Titulo: **Dafel | Control gerencial de alquileres**.
- Subtitulo: **Inventario, operacion y recaudo**.

## Fila de filtros

1. Anio y mes desde `DimFecha`.
2. Cliente desde `vw_DimCliente[razon_social]`.
3. Ciudad desde `vw_DimObra[ciudad]`.

## Fila de indicadores

1. Tarjeta `Valor vigente`.
2. Tarjeta `Recaudo neto`.
3. Tarjeta `Saldo pendiente`.
4. Tarjeta `Conversion comercial %`.

## Visuales principales

### Tendencia mensual

- Tipo: linea y columnas agrupadas.
- Eje: `vw_09_ValoresRecaudos[mes_confirmacion]`.
- Columnas: suma de `total_vigente`.
- Linea: suma de `recaudo_neto`.
- Titulo: **Valor vigente y recaudo neto por mes**.

### Clientes principales

- Tipo: barras horizontales.
- Eje: `vw_09_ValoresRecaudos[razon_social]`.
- Valor: suma de `total_vigente`.
- Filtro visual: diez primeros por valor.
- Titulo: **Valor vigente por cliente**.

### Valor por estado operativo

- Tipo: dona.
- Leyenda: `vw_08_PagosSaldos[estado_operativo]`.
- Valor: suma de `total_vigente`.
- Titulo: **Valor vigente por estado operativo**.

### Saldos prioritarios

- Tipo: tabla.
- Campos: numero de alquiler, cliente, estado operativo, total vigente,
  pagos netos y saldo pendiente desde `vw_08_PagosSaldos`.
- Filtro: saldo pendiente mayor que cero.
- Orden: saldo pendiente descendente.
- Titulo: **Alquileres con saldo pendiente**.

## Paginas de detalle implementadas

- **Inventario y disponibilidad:** consultas 01, 02, 06, 11 y 12.
- **Comercial y operaciones:** consultas 03, 04, 05 y 10.
- **Liquidacion y recaudo:** consultas 07, 08 y 09.

La explicacion funcional y el criterio de lectura de cada visual se documentan
en `GUIA_CONSULTAS_POWERBI.md`.

## Criterios visuales aplicados

- Cuadricula regular y margenes consistentes entre visuales.
- Titulos redactados en lenguaje funcional, sin depender del nombre tecnico de la columna.
- Color azul para valores principales y dorado como acento.
- Paginas agrupadas por proceso para evitar mezclar inventario, operacion y finanzas.
- Resumen gerencial con indicadores primero, filtros despues y detalle al final.

## Valores de control actuales

Al refrescar el modelo contra la carga instalada, sin filtros, deben observarse aproximadamente:

- 112 cotizaciones.
- 96 cotizaciones convertidas y 85,71 % de conversion.
- 96 alquileres.
- 466 unidades fisicas y 10 no aptas.
- 111.328.000 de valor vigente.
- 109.798.000 de pagos registrados.
- 1.705.000 de saldo pendiente calculado.
- 18 incidencias.
- 13 unidades de demanda faltante en la ultima evaluacion.

Los valores pueden variar si se agregan operaciones reales posteriormente.

