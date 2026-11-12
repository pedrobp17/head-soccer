extends EstadoResultadoPartido
class_name EstadoResultadoPartidoTorneo

func actualizar_resultado_modo(datos_pantalla : DatosPantallas) -> DatosPantallas:
	if datos_pantalla.torneo == null:
		push_warning("TORNEO sin torneo en datos_pantalla: se omite la progresión del bracket")
		return datos_pantalla
	datos_pantalla.torneo.set_partido_personaje_actual()
	if not ControladorPartido.enfrentamiento.gana_local():
		datos_pantalla.torneo.set_perdido()
	return datos_pantalla
