class_name Torneo

# Los 7 enemigos reales se reparten espaciados por el pool para que la animación tenga señuelos variados.
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
	partidos[estado].clear()
	for i in range(pool_jugadores.size() / 2.0):
		var enfrentamiento = Enfrentamientos.new()
		enfrentamiento.set_jugador_local(pool_jugadores[i*2].jugador, pool_jugadores[i*2].poder)
		enfrentamiento.set_jugador_visitante(pool_jugadores[i*2 + 1].jugador, pool_jugadores[i*2 + 1].poder)
		partidos[estado].append(enfrentamiento)

func extraer_enemigos_de_pool( array : Array[String]) -> Array[String]:
	var enemigos : Array = []
	for indice in INDICES_INICIO_POOL_ANIMACION_TRAGAPERRAS:
		enemigos.append(array[indice])
	return enemigos

func extraer_pool_animacion_tragaperras( indice : int ) -> Array[String]:
	var pool_animacion : Array = []
	var tamano := ultima_pool_enemigos.size()
	var indice_inicio : int = INDICES_INICIO_POOL_ANIMACION_TRAGAPERRAS[indice]

	for i in range(1, MAX_PERSONAJES_ANIMACION_TRAGAPERRAS):
		pool_animacion.append(ultima_pool_enemigos[posmod(indice_inicio + i, tamano)])

	pool_animacion.append(ultima_pool_enemigos[indice_inicio])
	
	return pool_animacion
	
func avanzar() -> void:
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
		
func set_partido_personaje_actual() -> void:
	if estado_actual < Estado.FINAL:
		var partido_jugado : Enfrentamientos =  partidos[estado_actual][0]
		var ganador : ConfiguracionJugadorPartido = partido_jugado.get_ganador()
		estado_actual += 1 as Estado
		var partido_por_jugar : Enfrentamientos = partidos[estado_actual][0]
		partido_por_jugar.config_jugador_local = ganador
		ProgresoPartida.progreso_general.guardar_torneo(self)
	elif estado_actual == Estado.FINAL:
		ganador = partidos[estado_actual][0].get_ganador()
		estado_actual += 1 as Estado
		ProgresoPartida.progreso_general.guardar_torneo(self)
		
func avanzar_enemigos() -> void:
	if estado_actual > Estado.SEMIS:
		return
		 
	for i in range(0, partidos[estado_actual].size(), 2):
		var partido_actual_1 : Enfrentamientos = partidos[estado_actual][i]
		var partido_actual_2 : Enfrentamientos = partidos[estado_actual][i + 1]
		partido_actual_1.get_random_marcador()
		partido_actual_2.get_random_marcador()
		var jugador_ganador_1 = partido_actual_1.get_ganador()
		var jugador_ganador_2 = partido_actual_2.get_ganador()
		var partido_siguiente : Enfrentamientos = Enfrentamientos.new()
		partido_siguiente.config_jugador_local = jugador_ganador_1
		partido_siguiente.config_jugador_visitante = jugador_ganador_2
		
		if partido_actual_1.config_jugador_local.jugador == configuracion_jugador_seleccionado.jugador:
			partido_siguiente.config_jugador_local = ConfiguracionJugadorPartido.new()
			partido_actual_1.reiniciar_resultado()
		
		partidos[estado_actual + 1].append(partido_siguiente)
		
	ProgresoPartida.progreso_general.guardar_torneo(self)

	
func set_perdido() -> void:
	perdido = true
	ProgresoPartida.progreso_general.guardar_torneo(self)

func actualizar_rondas_mostradas() -> void:
	ronda_mostrada = {
		Estado.CUARTOS : false,
		Estado.SEMIS : false,
		Estado.FINAL : false
	}
	
func set_ronda_mostrada( mostrada : bool, estado : Estado) -> void:
	ronda_mostrada[estado] = mostrada
	ProgresoPartida.progreso_general.guardar_torneo(self)
	
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
