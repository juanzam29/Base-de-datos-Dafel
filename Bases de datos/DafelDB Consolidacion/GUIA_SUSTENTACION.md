# Guia breve de sustentacion de DafelDB

## Orden recomendado

1. Presentar el problema de Dafel: solicitudes, cotizaciones, alquileres,
   inventario, devoluciones y recaudo.
2. Mostrar `DafelDB` como base principal y explicar que `DafelDB_Validacion` fue
   una base temporal de pruebas.
3. Abrir `Consultas_SQL/00_Ejecutar_Todas_Las_Consultas.sql` para demostrar que
   las doce consultas funcionan en SQL Server.
4. Explicar las consultas agrupadas en inventario, operacion y recaudo.
5. Abrir `PowerBI/DafelDB_Dashboard.pbix` para mostrar la visualizacion general.
6. Abrir `PowerBI/DafelDB_Dashboard_Consulta09.pbix` para explicar el dashboard
   individual de valores y recaudos.

## Demostracion principal de la consulta 09

Ejecutar `Consultas_SQL/09_Valores_Recaudos.sql` y explicar:

- El grano es una fila por evento financiero.
- Los valores aprobados no se repiten por cada pago o cargo.
- Los cargos, pagos y reembolsos usan la fecha real de cada movimiento.
- `recaudo_neto = pagos_recibidos - reembolsos_efectuados`.
- La ausencia de reembolsos efectivos produce cero; no es un error.

## Resultados de control

- 303 eventos financieros.
- 96 alquileres.
- Equipos: $75.563.000.
- Personal: $29.640.000.
- Transporte: $4.005.000.
- Cargos adicionales: $720.000.
- Pagos recibidos: $109.798.000.
- Reembolsos efectivos: $0.
- Recaudo neto: $109.798.000.

