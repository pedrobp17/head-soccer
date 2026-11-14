extends EstadoResultadoPartido
class_name EstadoResultadoPartidoArcade

func actualizar_resultado_modo(datos_pantalla: DatosPantallas) -> DatosPantallas:
	if datos_pantalla.isla_arcade == PantallaArcade.Islas.NONE:
		return datos_pantalla
	var enfrentamiento := ControladorPartido.enfrentamiento
	var gestor: GestorLogrosArcade = ControladorPartido.logros_arcade
	if gestor != null:
		var victoria: bool = enfrentamiento.gana_local()
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GANA_PARTIDO, victoria)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.PORTERIA, enfrentamiento.goles_visitante == 0)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.DIFERENCIA, enfrentamiento.goles_local - enfrentamiento.goles_visitante)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.TIEMPO_EXTRA, ControladorPartido.estado_actual.datos_juego.tiempo_extra)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL_CABEZAZO, ControladorPartido.estadisticas_partido_jugador_local.tipos_goles[LogrosArcadeHelper.Ids.GOL_CABEZAZO])
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL_PATADA, ControladorPartido.estadisticas_partido_jugador_local.tipos_goles[LogrosArcadeHelper.Ids.GOL_PATADA])
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL_PATADA_CABEZAZO, min(ControladorPartido.estadisticas_partido_jugador_local.tipos_goles[LogrosArcadeHelper.Ids.GOL_CABEZAZO], ControladorPartido.estadisticas_partido_jugador_local.tipos_goles[LogrosArcadeHelper.Ids.GOL_PATADA]))
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL_PRIMERO, ControladorPartido.estadisticas_partido_jugador_local.primer_gol_jugador_local)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL_TIEMPO, floori(ControladorPartido.estadisticas_partido_jugador_local.ultimo_gol_local_transcurrido))
		var tiempo_extra: bool = ControladorPartido.estado_actual.datos_juego.tiempo_extra
		var ventaja: int = 0 if tiempo_extra else floori(ControladorPartido.estadisticas_partido_jugador_local.inicio_ventaja_local)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.VENTAJA, ventaja)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.IR_PERDIENDO, ControladorPartido.estadisticas_partido_jugador_local.mayor_diferencia_perdiendo_local)
		gestor.registrar_logro(LogrosArcadeHelper.Ids.GOL, enfrentamiento.goles_local if ControladorPartido.estadisticas_partido_jugador_local.mayor_diferencia_perdiendo_local == 0 else 0)
		gestor.evaluar_logros()
	ControladorPartido.logros_arcade = null
	ControladorPartido.estadisticas_partido_jugador_local = null
	if enfrentamiento.gana_local():
		ProgresoPartida.progreso_general.completar_nivel_arcade(
			datos_pantalla.isla_arcade, enfrentamiento.config_jugador_visitante.jugador, ProgresoArcade.get_nivel_rival(datos_pantalla.isla_arcade, datos_pantalla.nivel_arcade))
	return datos_pantalla
