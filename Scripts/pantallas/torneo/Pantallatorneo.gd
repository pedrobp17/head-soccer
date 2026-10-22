extends Pantallas
class_name PantallaTorneo

signal fin_animacion_torneo
signal fin_animacion_bracket_line

const NUM_PARTICIPANTES := 8
const PAUSA_RONDA := 0.8

@onready var placeholders_posiciones_imagenes : Dictionary = {
	Torneo.Estado.CUARTOS : %Cuartos,
	Torneo.Estado.SEMIS : %Semis,
	Torneo.Estado.FINAL : %Final,
	Torneo.Estado.COMPLETADO : %Ganador
}
@onready var brackets_line : Dictionary = {
	Torneo.Estado.CUARTOS : %CuartosLineBrackets, 
	Torneo.Estado.SEMIS : %SemisLineBrackets
}

var torneo : Torneo = null
var cartas_jugadores_activos : Array[CartasSeleccionTorneo] = []
var torneo_simulado := false
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
		
		elif torneo.estado_actual == Torneo.Estado.COMPLETADO:
			ProgresoPartida.progreso_general.terminar_torneo()
			transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)
		
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
		if not is_inside_tree():
			return
			
	refresh_brackets()
	if torneo.estado_actual == Torneo.Estado.CUARTOS and torneo.ronda_mostrada[torneo.estado_actual + 1]:
		refresh_brackets_line_estado(torneo.estado_actual, false)
	else:
		refresh_brackets_line()
	
	if torneo.estado_actual < Torneo.Estado.FINAL and !torneo.ronda_mostrada[torneo.estado_actual + 1]:
		set_ganadores_siguiente_ronda(torneo.estado_actual + 1)
		await  fin_animacion_torneo
		if not is_inside_tree():
			return
		refresh_ganadores( torneo.estado_actual )
		refresh_brackets_line_estado(torneo.estado_actual)
		await fin_animacion_bracket_line
		
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
				pintar_resultado_partido(carta_local, carta_visitante, partido_actual)
			elif [partido_actual.config_jugador_local.jugador, partido_actual.config_jugador_visitante.jugador].has(datos_pantalla.confing_jugador.jugador) and torneo.estado_actual == estado:
				var carta_jugador := carta_local if partido_actual.config_jugador_local.jugador == datos_pantalla.confing_jugador.jugador else carta_visitante 
				carta_jugador.set_jugador_seleccionado()
				ControladorPartido.enfrentamiento = partido_actual
	else:
		cartas[0].inicializar(torneo.ganador.jugador)	 
		
func refresh_brackets_line_estado(estado : Torneo.Estado, animar : bool = true) -> void:
	var bracket_line_estado : Array[Node] = brackets_line[estado].get_children()
	var array_animaciones : Array[Tween] = []
	for i in range(1,torneo.partidos[estado].size()):
			var partido : Enfrentamientos = torneo.partidos[estado][i]
			var ganador : ConfiguracionJugadorPartido = partido.get_ganador()
			var indice_ganador = 0 if ganador == partido.config_jugador_local else 1
			var bracket_line_enseñar : LineaBraquet = bracket_line_estado[2*i + indice_ganador]
			if animar:	
				array_animaciones.append(bracket_line_enseñar.animar())
			else:
				bracket_line_enseñar.set_max()
				
	for tween in array_animaciones:
		await tween.finished
	
	fin_animacion_bracket_line.emit()

func refresh_brackets_line() -> void:
	var estado_actual = torneo.estado_actual
	if estado_actual == Torneo.Estado.COMPLETADO:
		estado_actual -= 1
		 
	for estado in range(estado_actual - 1, -1, -1):
		assert(brackets_line[estado].get_child_count() == 2*torneo.partidos[estado].size(), "no hay suficientes partidos para settear las lineas de los brackets")
		var bracket_line_estado : Array[Node] = brackets_line[estado].get_children()
		for i in torneo.partidos[estado].size():
			var partido : Enfrentamientos = torneo.partidos[estado][i]
			var ganador : ConfiguracionJugadorPartido = partido.get_ganador()
			var indice_ganador = 0 if ganador == partido.config_jugador_local else 1
			var bracket_line_enseñar : LineaBraquet = bracket_line_estado[2*i + indice_ganador]
			bracket_line_enseñar.set_max()
		
func refresh_ganadores( estado : Torneo.Estado ) -> void: 
	var cartas = get_placeholder_cartas_por_estado(estado)
	var partidos : Array = torneo.partidos[estado]
	assert(cartas.size() == 2 * partidos.size())
	for i in range(1, partidos.size()):
		var partido_actual : Enfrentamientos = partidos[i]
		pintar_resultado_partido(cartas[i*2], cartas[i*2 + 1], partido_actual)
			
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

	torneo_simulado = true

func eleccion_personajes_cuartos() -> void:
	animando = true
	var cartas_cuartos = get_placeholder_cartas_por_estado(Torneo.Estado.CUARTOS)
	var animaciones : Array[Tween] = []
	for i in NUM_PARTICIPANTES - 1:
		var pool_animacion_tragaperras = torneo.extraer_pool_animacion_tragaperras(i)
		animaciones.append( cartas_cuartos[i + 1].animacion_tragaperras(pool_animacion_tragaperras))
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
	for i in range(1, cartas.size()):
		var partido_actual : Enfrentamientos = torneo.partidos[estado - 1][i]
		var primer_jugador = partido_actual.ganador
		var segundo_jugador = partido_actual.config_jugador_local.jugador if partido_actual.ganador != partido_actual.config_jugador_local.jugador else partido_actual.config_jugador_visitante.jugador 
		animaciones.append( cartas[i].animacion_tragaperras([primer_jugador, segundo_jugador]))
	
	for tween in animaciones:
		await tween.finished
	fin_animacion_torneo.emit()
	animando = false

func pintar_resultado_partido(carta_local : CartasSeleccionTorneo, carta_visitante : CartasSeleccionTorneo, partido : Enfrentamientos) -> void:
	var ganador = partido.get_ganador().jugador
	var jugador_local = partido.config_jugador_local.jugador
	var indice_local = 0 if ganador == jugador_local else 1

	var carta_ganador := carta_local if ganador == jugador_local else carta_visitante
	var carta_perdedor := carta_visitante if ganador == jugador_local else carta_local

	carta_ganador.set_ganador(partido.marcador_final[indice_local])
	carta_perdedor.set_perdedor(partido.marcador_final[1 - indice_local])
	
func set_jugador_seleccionado() -> void:
	var contenedor: Node = placeholders_posiciones_imagenes[Torneo.Estado.CUARTOS]
	var carta : CartasSeleccionTorneo = contenedor.get_children()[0]
	carta.inicializar( datos_pantalla.torneo.configuracion_jugador_seleccionado.jugador)
	carta.set_jugador_seleccionado()
