extends EstadoResultadoPartido
class_name EstadoResultadoPartidoArcade

func actualizar_resultado_modo(datos_pantalla: DatosPantallas) -> DatosPantallas:
	if datos_pantalla.isla_arcade == PantallaArcade.Islas.NONE:
		return datos_pantalla
	var enfrentamiento := ControladorPartido.enfrentamiento
	var gestor: GestorLogrosArcade = ControladorPartido.logros_arcade
	if gestor != null:
		var sin_tiempo_extra: bool = not ControladorPartido.estado_actual.datos_juego.tiempo_extra
		gestor.registrar_logro(LogrosArcadeHelper.LogrosGenerales.GANAR_SIN_TIEMPO_EXTRA,
			enfrentamiento.gana_local() and sin_tiempo_extra)
		gestor.registrar_logro(LogrosArcadeHelper.LogrosGenerales.METER_5_GOLES, enfrentamiento.goles_local)
		gestor.evaluar_logros()
	ControladorPartido.logros_arcade = null
	
	if enfrentamiento.gana_local():
		ProgresoPartida.progreso_general.completar_nivel_arcade(
			datos_pantalla.isla_arcade, enfrentamiento.config_jugador_visitante.jugador, ProgresoArcade.get_nivel_rival(datos_pantalla.isla_arcade, datos_pantalla.nivel_arcade))
	return datos_pantalla
