# Power BI - DafelDB

Este directorio contiene el informe final `DafelDB_Dashboard.pbix`, conectado al modelo analítico del esquema `bi` de la base principal `DafelDB`.

## Contenido del informe

El archivo tiene cuatro páginas organizadas por proceso:

1. **Resumen gerencial**: valor vigente, recaudo, saldo, conversión comercial, filtros y visuales de tendencia, clientes y estado operativo.
2. **Inventario y disponibilidad**: inventario disponible, disponibilidad futura, utilización, inspecciones y demanda no atendida.
3. **Comercial y operaciones**: despachos pendientes, cotizaciones, retrasos e incidencias.
4. **Liquidación y recaudo**: valor vigente, cartera por cliente y evolución mensual del recaudo.

Las doce consultas del Excel están representadas en las páginas de detalle. El modelo importa 17 vistas/tablas analíticas, contiene una tabla de medidas y usa relaciones activas de uno a varios con dirección de filtro única.

## Archivos útiles

- `DafelDB_Dashboard.pbix`: informe editable y entregable principal.
- `GUIA_CONSULTAS_POWERBI.md`: explicación de cada consulta y de su lectura.
- `Dashboard_Dafel_Especificacion.md`: estructura funcional del tablero.
- `RELACIONES_MODELO.md`: relaciones y cardinalidad del modelo.
- `Medidas_DAX.md`: catálogo de medidas.
- `Tema_Dafel.json`: colores corporativos reutilizables.
- `Evidencias/`: capturas limpias de las cuatro páginas.

## Actualización

1. Abrir el PBIX en Power BI Desktop.
2. Comprobar que SQL Server `DESKTOP-5K1DA26\SQLEXPRESS` esté disponible.
3. Confirmar que la base seleccionada sea `DafelDB`.
4. Usar **Inicio > Actualizar** y revisar que no existan errores.
5. Guardar el archivo antes de entregarlo.

Los datos con códigos `DAFEL-DEMO-*`, `DAFEL-BI-*`, `SOL-BI-*` y `ALQ-BI-*` son ficticios y se cargaron para demostración académica.

## Estado visual

El informe se dejó con cuadrículas consistentes, márgenes uniformes, títulos funcionales, colores corporativos y jerarquía de lectura de izquierda a derecha. Los pendientes para una publicación empresarial están descritos en `PENDIENTES_DASHBOARD_EMPRESARIAL.md`.
