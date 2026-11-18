// Referencia de conexion. En Power BI cada bloque debe crearse como una consulta independiente.
// La autenticacion se selecciona en la interfaz y nunca se guarda aqui una contrasena.

// Parametros sugeridos:
// ServidorSQL = "DESKTOP-5K1DA26\\SQLEXPRESS"
// BaseSQL = "DafelDB"

let
    Fuente = Sql.Database("DESKTOP-5K1DA26\\SQLEXPRESS", "DafelDB"),
    Datos = Fuente{[Schema="bi", Item="vw_01_Inventario"]}[Data]
in
    Datos

// Repetir el bloque anterior sustituyendo Item por:
// DimFecha
// vw_DimCliente
// vw_DimObra
// vw_DimRecurso
// vw_DimEmpleado
// vw_02_DisponibilidadFutura
// vw_03_Cotizaciones
// vw_04_AlquileresActivos
// vw_05_DespachosDevoluciones
// vw_06_UtilizacionEquipos
// vw_07_Liquidacion
// vw_08_PagosSaldos
// vw_09_ValoresRecaudos
// vw_10_Incidencias
// vw_11_Inspecciones
// vw_12_DemandaNoAtendida

