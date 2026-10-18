class_name Torneo

const INDICES_INICIO_POOL_ANIMACION_TRAGAPERRAS = [1,3,6,8,11,13,15]
const MAX_PERSONAJES_ANIMACION_TRAGAPERRAS = 5

enum Estado {CUARTOS, SEMIS, FINAL, COMPLETADO}

var estado_actual : Estado = Estado.CUARTOS
var partidos := {
	Estado.CUARTOS : [],
	Estado.SEMIS : [],
	Estado.FINAL : []
}
var ronda_mostrada : Dictionary[Estado, bool]
var ganador : ConfiguracionJugadorPartido = null
var configuracion_jugador_seleccionado := ConfiguracionJugadorPartido.new()
var ultima_pool_enemigos : Array = []
var perdido : bool = false	

func _init(config_jugador : ConfiguracionJugadorPartido = null) -> void:
	if config_jugador == null:
		return 
		
	perdido = false
	actualizar_rondas_mostradas()
	configuracion_jugador_seleccionado = ConfiguracionJugadorPartido.new().setup(config_jugador.jugador, config_jugador.poder)
	var pool_random_jugadores : Array[ConfiguracionJugadorPartido] = [configuracion_jugador_seleccionado]
	pool_random_jugadores.append_array(get_pool_random_enemigos())
	crear_bracket(estado_actual, pool_random_jugadores)
	ProgresoPartida.progreso_general.guardar_torneo(self)

func get_pool_random_enemigos() -> Array[ConfiguracionJugadorPartido]:
	var pool_jugadores = ProgresoPartida.personajes_desbloqueados.get_nombres_personajes()
	pool_jugadores.erase(configuracion_jugador_seleccionado.jugador)
	pool_jugadores.shuffle()
	ultima_pool_enemigos = pool_jugadores
	pool_jugadores = extraer_enemigos_de_pool(pool_jugadores)
	var pool_jugadores_configurados : Array[ConfiguracionJugadorPartido]= []
	for i in pool_jugadores.size():
		var configuracion_jugador_enemigo = ConfiguracionJugadorPartido.new()
		pool_jugadores_configurados.append(configuracion_jugador_enemigo.setup(pool_jugadores[i], "mano_magica"))
	
	return pool_jugadores_configurados
		
func crear_bracket(estado : Estado, pool_jugadores : Array[ConfiguracionJugadorPartido]) -> void:
	for i in range(pool_jugadores.size() / 2.0):
		var enfrentamiento = Enfrentamientos.new()
		enfrentamiento.set_jugador_local(pool_jugadores[i*2].jugador, pool_jugadores[i*2].poder)
		enfrentamiento.set_jugador_visitante(pool_jugadores[i*2 + 1].jugador, pool_jugadores[i*2 + 1].poder)
		partidos[estado].append(enfrentamiento)

func extraer_enemigos_de_pool( array : Array) -> Array:
	var enemigos : Array = []
	for indice in INDICES_INICIO_POOL_ANIMACION_TRAGAPERRAS:
		enemigos.append(array[indice])
	return enemigos

func extraer_pool_animacion_tragaperras( indice : int ) -> Array:
	var pool_animacion : Array = []
	var indice_inicio = INDICES_INICIO_POOL_ANIMACION_TRAGAPERRAS[indice]
	pool_animacion.append_array(ultima_pool_enemigos.slice(indice_inicio + 1, indice_inicio + 4 ))
	pool_animacion.append(ultima_pool_enemigos[indice_inicio])
	return pool_animacion
	
func avanzar(guardar : bool = true) -> void:
	if estado_actual < Estado.COMPLETADO:
		var partidos_actuales : Array = partidos[estado_actual]
		var ganadores : Array[ConfiguracionJugadorPartido] = []
		for partido_actual : Enfrentamientos in partidos_actuales:
			if partido_actual.ganador.is_empty():
				partido_actual.get_random_marcador()
			ganadores.append(partido_actual.get_ganador())
		estado_actual = estado_actual + 1 as Estado
		if estado_actual == Estado.COMPLETADO:
			ganador = ganadores[0]
		else:
			crear_bracket(estado_actual, ganadores)
		if guardar:
			ProgresoPartida.progreso_general.guardar_torneo(self)

func avanzar_enemigos() -> Array:
	if estado_actual > Estado.SEMIS:
		return []
	var ronda_avanzada : Array[ConfiguracionJugadorPartido] = []
	var ronda_actual : Array[Enfrentamientos] = partidos[estado_actual]
	for i in range(1, ronda_actual.size()):
		ronda_actual[i].get_random_marcador()
		ronda_avanzada.append(ronda_actual[i].get_ganador())
	return ronda_avanzada
	
func set_perdido() -> void:
	perdido = true
	ProgresoPartida.progreso_general.guardar_torneo(self)

func actualizar_rondas_mostradas() -> void:
	ronda_mostrada = {
		Estado.CUARTOS : false,
		Estado.SEMIS : false,
		Estado.FINAL : false
	}

func serialize() -> Dictionary:
	var partidos_data := {}
	for estado in partidos.keys():
		var lista := []
		for partido : Enfrentamientos in partidos[estado]:
			lista.append(partido.serialize())
		partidos_data[Estado.keys()[estado]] = lista

	var rondas_mostradas_data := {}
	for estado in ronda_mostrada.keys():
		rondas_mostradas_data[Estado.keys()[estado]] = ronda_mostrada[estado]

	return {
		"estado_actual": Estado.keys()[estado_actual],
		"ultima_pool_enemigos" : ultima_pool_enemigos,
		"jugador": configuracion_jugador_seleccionado.serialize(),
		"perdido" : perdido,
		"ganador": ganador.serialize() if ganador != null else null,
		"partidos": partidos_data,
		"ronda_mostrada": rondas_mostradas_data
	}


static func deserialize(data: Dictionary) -> Torneo:
	if data.is_empty():
		return null
	var torneo := Torneo.new()
	torneo.actualizar_rondas_mostradas()  # valores por defecto (todo en false)
	torneo.estado_actual = Estado[data["estado_actual"]]
	torneo.ultima_pool_enemigos = data["ultima_pool_enemigos"]
	torneo.perdido = data["perdido"]
	torneo.configuracion_jugador_seleccionado = ConfiguracionJugadorPartido.deserialize(data["jugador"])
	if data["ganador"] != null:
		torneo.ganador = ConfiguracionJugadorPartido.deserialize(data["ganador"])

	for nombre_estado in data["partidos"]:
		var estado : Estado = Estado[nombre_estado]
		torneo.partidos[estado] = []
		for partido_data in data["partidos"][nombre_estado]:
			torneo.partidos[estado].append(Enfrentamientos.deserialize(partido_data))

	if data.has("ronda_mostrada"):
		for nombre_estado in data["ronda_mostrada"]:
			torneo.ronda_mostrada[Estado[nombre_estado]] = data["ronda_mostrada"][nombre_estado]

	return torneo
