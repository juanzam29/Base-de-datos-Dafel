# Dashboard individual - Consulta 09

## Objetivo

Este entregable desarrolla un dashboard completo a partir de una consulta SQL específica, tal como solicita el enunciado académico. El archivo principal es `DafelDB_Dashboard_Consulta09.pbix` y utiliza como fuente analítica la vista `bi.vw_09_ValoresRecaudos` de `DafelDB`.

El dashboard general del proyecto permanece en `DafelDB_Dashboard.pbix` y no fue reemplazado.

## Consulta seleccionada

**Consulta 09 - Valores y recaudos**.

La vista reúne, por alquiler:

- fecha y mes de confirmación;
- cliente, obra y ciudad;
- valores de equipos, personal, transporte y otros conceptos;
- cargos adicionales y ajustes;
- valor vigente;
- recaudo bruto;
- reembolsos efectivos;
- recaudo neto.

## Contenido del dashboard

- Valor vigente.
- Recaudo neto.
- Saldo por recaudar: valor vigente menos recaudo neto.
- Porcentaje recaudado: recaudo neto dividido entre valor vigente.
- Filtros de año, mes, cliente y ciudad.
- Comparación mensual entre valor vigente y recaudo neto.
- Valor vigente por cliente.
- Recaudo neto por ciudad.
- Detalle por alquiler y cliente con valores financieros.

## Alcance del modelo

El PBIX contiene una sola página llamada **Dashboard Consulta 09**. En el panel de datos se dejaron visibles únicamente la vista `bi.vw_09_ValoresRecaudos` y la tabla de medidas. Las demás tablas del modelo heredado se ocultaron en este archivo independiente y no forman parte del análisis presentado.

## Archivos

- `DafelDB_Dashboard_Consulta09.pbix`: dashboard individual editable.
- `Consulta09_ValoresRecaudos.sql`: consulta ejecutable en SQL Server.
- `Vista_previa_Dashboard_Consulta09.png`: evidencia visual.
