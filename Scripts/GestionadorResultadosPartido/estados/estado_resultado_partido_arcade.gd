extends EstadoResultadoPartido
class_name EstadoResultadoPartidoArcade

func actualizar_resultado_modo(datos_pantalla : DatosPantallas) -> DatosPantallas:

	if datos_pantalla.isla_arcade == PantallaArcade.Islas.NONE:
		return datos_pantalla
	var enfrentamiento := ControladorPartido.enfrentamiento
	
	if enfrentamiento.gana_local():
		ProgresoPartida.progreso_general.completar_nivel_arcade(
			datos_pantalla.isla_arcade, enfrentamiento.config_jugador_visitante.jugador, datos_pantalla.nivel_arcade)
	return datos_pantalla
