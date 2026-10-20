extends Pantallas
class_name PantallaTorneo

signal fin_animacion_torneo

const NUM_PARTICIPANTES := 8
const PAUSA_RONDA := 0.8

@onready var placeholders_posiciones_imagenes : Dictionary = {
	Torneo.Estado.CUARTOS : %Cuartos,
	Torneo.Estado.SEMIS : %Semis,
	Torneo.Estado.FINAL : %Final,
	Torneo.Estado.COMPLETADO : %Ganador
}

var torneo : Torneo = null
var cartas_jugadores_activos : Array[CartasSeleccionTorneo] = []
var torneo_simulado := false
var simulando := false
var animando := false

func _input(event: InputEvent) -> void:
	if animando:
		return
		
	if event.is_action_pressed("ui_select"):
		if torneo.perdido:
			ProgresoPartida.progreso_general.terminar_torneo()
			
			if not torneo_simulado:
				completar_torneo()
			else:
				transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)
				
		elif torneo.estado_actual < Torneo.Estado.COMPLETADO:
			transicion_pantallas(HeadSoccer.Pantalla.JUGANDO, datos_pantalla)

	if event.is_action_pressed("p1_back"):
		ControladorPartido.enfrentamiento = Enfrentamientos.new()
		transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)

func _ready() -> void:
	torneo = datos_pantalla.torneo
	set_jugador_seleccionado()
	if !torneo.ronda_mostrada[Torneo.Estado.CUARTOS]:
		eleccion_personajes_cuartos()
		torneo.set_ronda_mostrada(true, Torneo.Estado.CUARTOS)
		await fin_animacion_torneo
		
	refresh_brackets()
	
	if torneo.estado_actual < Torneo.Estado.FINAL and !torneo.ronda_mostrada[torneo.estado_actual + 1]:
		set_ganadores_siguiente_ronda(torneo.estado_actual + 1)
		await  fin_animacion_torneo
		refresh_ganadores( torneo.estado_actual )
	
func refresh_brackets() -> void:
	for estado in range(torneo.estado_actual + 1):
		refresh_bracket_estado(estado)
	
	if torneo.estado_actual < Torneo.Estado.FINAL and torneo.ronda_mostrada[torneo.estado_actual + 1]:
		refresh_bracket_estado(torneo.estado_actual + 1)
		
func refresh_bracket_estado(estado : Torneo.Estado) -> void:
	var cartas := get_placeholder_cartas_por_estado(estado)
	if estado < Torneo.Estado.COMPLETADO:
		var partidos : Array = torneo.partidos[estado]
		assert(cartas.size() == 2 * partidos.size())
		for i in range(partidos.size()):
			var partido_actual : Enfrentamientos = partidos[i]
			var carta_local : CartasSeleccionTorneo = cartas[ i * 2 ]
			var carta_visitante : CartasSeleccionTorneo = cartas[ i * 2 + 1 ]
			carta_local.inicializar(partido_actual.config_jugador_local.jugador)
			carta_visitante.inicializar(partido_actual.config_jugador_visitante.jugador)
			if not partido_actual.ganador.is_empty():
				var ganador = partido_actual.get_ganador().jugador
				var jugador_local = partido_actual.config_jugador_local.jugador
				var carta_ganador := carta_local if ganador == jugador_local else carta_visitante
				var carta_perdedor := carta_visitante if ganador == jugador_local else carta_local
				carta_ganador.set_ganador(partido_actual.marcador_final[0 if ganador == jugador_local else 1 ])
				carta_perdedor.set_perdedor(partido_actual.marcador_final[1 if ganador == jugador_local else 0 ])
			elif [partido_actual.config_jugador_local.jugador, partido_actual.config_jugador_visitante.jugador].has(datos_pantalla.confing_jugador.jugador) and torneo.estado_actual == estado:
				var carta_jugador := carta_local if partido_actual.config_jugador_local.jugador == datos_pantalla.confing_jugador.jugador else carta_visitante 
				carta_jugador.set_jugador_seleccionado()
				ControladorPartido.enfrentamiento = partido_actual
	else:
		cartas[0].inicializar(torneo.ganador.jugador)	 
	
func refresh_ganadores( estado : Torneo.Estado ) -> void: 
	var cartas = get_placeholder_cartas_por_estado(estado)
	var partidos : Array = torneo.partidos[estado]
	assert(cartas.size() == 2 * partidos.size())
	for i in range(partidos.size() - 1):
		var partido_actual : Enfrentamientos = partidos[i]
		var carta_local : CartasSeleccionTorneo = cartas[ i * 2 ]
		var carta_visitante : CartasSeleccionTorneo = cartas[ i * 2 + 1 ]
		var ganador = partido_actual.get_ganador().jugador
		var jugador_local = partido_actual.config_jugador_local.jugador
		var carta_ganador := carta_local if ganador == jugador_local else carta_visitante
		var carta_perdedor := carta_visitante if ganador == jugador_local else carta_local
		carta_ganador.set_ganador(partido_actual.marcador_final[0 if ganador == jugador_local else 1 ])
		carta_perdedor.set_perdedor(partido_actual.marcador_final[1 if ganador == jugador_local else 0 ])
			
func get_placeholder_cartas_por_estado(estado : Torneo.Estado) -> Array[CartasSeleccionTorneo]:
	var cartas : Array[CartasSeleccionTorneo] = []
	var contenedor: Control = placeholders_posiciones_imagenes[estado]
	if !contenedor.visible:
		contenedor.show()
	for placeholder in contenedor.get_children():
			cartas.append(placeholder)
	return cartas

func completar_torneo() -> void:
	torneo_simulado = true
	
	while torneo.estado_actual < Torneo.Estado.COMPLETADO:
		var estado := torneo.estado_actual

		for partido : Enfrentamientos in torneo.partidos[estado]:
			if partido.ganador.is_empty():
				partido.get_random_marcador()
		refresh_bracket_estado(estado)

		await get_tree().create_timer(PAUSA_RONDA).timeout
		if not is_inside_tree():
			return
			
		torneo.avanzar()
		refresh_bracket_estado(torneo.estado_actual)
		
		await get_tree().create_timer(PAUSA_RONDA).timeout
		if not is_inside_tree():
			return

	simulando = false
	torneo_simulado = true

func eleccion_personajes_cuartos() -> void:
	animando = true
	var cartas_cuartos = get_placeholder_cartas_por_estado(Torneo.Estado.CUARTOS)
	var animaciones : Array[Tween] = []
	for i in NUM_PARTICIPANTES - 1:
		var pool_animacion_tragaperras = torneo.extraer_pool_animacion_tragaperras(i)
		animaciones.append( cartas_cuartos[i].animacion_tragaperras(pool_animacion_tragaperras))
	for tween in animaciones:
		await tween.finished
	fin_animacion_torneo.emit()
	animando = false
		
func set_ganadores_siguiente_ronda( estado : Torneo.Estado) -> void:
	animando = true
	torneo.set_ronda_mostrada(true, estado)
	var cartas = get_placeholder_cartas_por_estado(estado)
	var animaciones : Array[Tween]
	torneo.avanzar_enemigos()
	for i in range(0, cartas.size() - 1):
		var partido_actual : Enfrentamientos = torneo.partidos[estado - 1][i]
		var primer_jugador = partido_actual.ganador
		var segundo_jugador = partido_actual.config_jugador_local.jugador if partido_actual.ganador != partido_actual.config_jugador_local.jugador else partido_actual.config_jugador_visitante.jugador 
		animaciones.append( cartas[i].animacion_tragaperras([primer_jugador, segundo_jugador]))
	
	for tween in animaciones:
		await tween.finished
	fin_animacion_torneo.emit()
	animando = false

func set_jugador_seleccionado() -> void:
	var contenedor: Node = placeholders_posiciones_imagenes[Torneo.Estado.CUARTOS]
	var carta : CartasSeleccionTorneo = contenedor.get_children()[contenedor.get_child_count() - 1]
	carta.inicializar( datos_pantalla.torneo.configuracion_jugador_seleccionado.jugador)
	carta.set_jugador_seleccionado()
