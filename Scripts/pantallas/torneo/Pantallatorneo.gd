extends Pantallas
class_name PantallaTorneo

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

func _input(event: InputEvent) -> void:
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
	eleccion_personajes_cuartos()
	

func refresh_brackets() -> void:
	for estado in range(torneo.estado_actual + 1):
		refresh_bracket_estado(estado)
	set_ganadores_siguiente_ronda(torneo.estado_actual + 1)
	
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
	
func get_placeholder_cartas_por_estado(estado : Torneo.Estado) -> Array[CartasSeleccionTorneo]:
	var cartas : Array[CartasSeleccionTorneo] = []
	var contenedor: Node = placeholders_posiciones_imagenes[estado]
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
			
		torneo.avanzar(false)
		refresh_bracket_estado(torneo.estado_actual)
		
		await get_tree().create_timer(PAUSA_RONDA).timeout
		if not is_inside_tree():
			return

	simulando = false
	torneo_simulado = true

func eleccion_personajes_cuartos() -> void:
	var cartas_cuartos = get_placeholder_cartas_por_estado(Torneo.Estado.CUARTOS)
	var animaciones : Array[Tween] = []
	for i in NUM_PARTICIPANTES - 1:
		var pool_animacion_tragaperras = torneo.extraer_pool_animacion_tragaperras(i)
		animaciones.append( cartas_cuartos[i + 1].animacion_tragaperras(pool_animacion_tragaperras))
	for tween in animaciones:
		await tween.finished
		
func set_ganadores_siguiente_ronda( estado : Torneo.Estado) -> void:
	pass
