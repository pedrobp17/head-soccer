extends RefCounted
class_name GestionadorResultadosPartidos

var estado_actual: EstadoResultadoPartido = null
var creador_estados_resultados := CreadorEstadosResultados.new()
var resultado_procesado: bool = false
var datos_resultado: DatosPantallas = null
var salida_iniciada: bool = false

func actualizar_datos_juego(datos_pantalla: DatosPantallas) -> DatosPantallas:
	if resultado_procesado:
		return datos_resultado
	# El reloj a cero tambien puede significar tiempo extra: solo FIN confirma el resultado.
	if not ControladorPartido.estado_actual is EstadoJuegoFin:
		return datos_pantalla
	resultado_procesado = true
	estado_actual = creador_estados_resultados.get_fresh_state(ProgresoPartida.progreso_general.get_modo_jugado())
	datos_resultado = estado_actual.actualizar_resultado_modo(datos_pantalla)
	if ControladorPartido.enfrentamiento.gana_local():
		ProgresoPartida.personajes_desbloqueados.set_partidos_ganados(
			ControladorPartido.enfrentamiento.config_jugador_local.jugador)
		ProgresoPartida.personajes_desbloqueados.guardar_progreso()
	return datos_resultado

func gestionar_back(campo: Campo) -> void:
	if salida_iniciada:
		return
	salida_iniciada = true
	campo.fin_timer.stop()
	var datos: DatosPantallas = actualizar_datos_juego(campo.datos_pantalla)
	ControladorPartido.parar_juego()
	if datos.torneo != null and not resultado_procesado:
		ControladorPartido.enfrentamiento.reiniciar_resultado()
	ControladorPartido.enfrentamiento = Enfrentamientos.new()
	ControladorPartido.logros_arcade = null
	var modo: ProgresoGlobal.Modos = ProgresoPartida.progreso_general.get_modo_jugado()
	if modo == ProgresoGlobal.Modos.ARCADE:
		campo.transicion_pantallas(MenuDeslizanteModosJuego.get_pantalla_asociada(modo), datos)
	else:
		campo.transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)
