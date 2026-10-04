class_name Torneo

enum Estado {CUARTOS, SEMIS, FINAL, COMPLETADO}

var estado_actual : Estado = Estado.CUARTOS
var partidos := {
	Estado.CUARTOS : [],
	Estado.SEMIS : [],
	Estado.FINAL : []
}

var ganador := ""
var configuracion_jugador_seleccionado := ConfiguracionJugadorPartido.new()

func _init(config_jugador : ConfiguracionJugadorPartido) -> void:
	configuracion_jugador_seleccionado = config_jugador
	var pool_random_jugadores : Array[ConfiguracionJugadorPartido] = [config_jugador]
	pool_random_jugadores.append_array(get_pool_random_enemigos())
	
	crear_bracket(estado_actual, pool_random_jugadores)

func get_pool_random_enemigos() -> Array[ConfiguracionJugadorPartido]:
	var pool_jugadores = DatosJugadores.get_array_jugadores()
	pool_jugadores.erase(DatosJugadores.get_jugador(configuracion_jugador_seleccionado.jugador))
	pool_jugadores.shuffle()
	pool_jugadores = pool_jugadores.slice(0, 7)
	var pool_jugadores_configurados : Array[ConfiguracionJugadorPartido]= []
	for i in pool_jugadores.size():
		var configuracion_jugador_enemigo = ConfiguracionJugadorPartido.new()
		pool_jugadores_configurados.append(configuracion_jugador_enemigo.setup(pool_jugadores[i].nombre, pool_jugadores[i].poderes[randi_range(0,1)]))
	
	return pool_jugadores_configurados
		
func crear_bracket(estado : Estado, pool_jugadores : Array[ConfiguracionJugadorPartido]) -> void:
	for i in range(pool_jugadores.size() / 2.0):
		var enfrentamiento = Enfrentamientos.new()
		enfrentamiento.set_jugador_local(pool_jugadores[i*2].jugador, pool_jugadores[i*2].poder)
		enfrentamiento.set_jugador_visitante(pool_jugadores[i*2 + 1].jugador, pool_jugadores[i*2 + 1].poder)
		partidos[estado].append(enfrentamiento)
