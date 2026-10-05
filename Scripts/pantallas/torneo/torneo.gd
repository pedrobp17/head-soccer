class_name Torneo

enum Estado {CUARTOS, SEMIS, FINAL, COMPLETADO}

var estado_actual : Estado = Estado.CUARTOS
var partidos := {
	Estado.CUARTOS : [],
	Estado.SEMIS : [],
	Estado.FINAL : []
}

var ganador : ConfiguracionJugadorPartido = null
var configuracion_jugador_seleccionado := ConfiguracionJugadorPartido.new()

func _init(config_jugador : ConfiguracionJugadorPartido) -> void:
	configuracion_jugador_seleccionado = config_jugador
	var pool_random_jugadores : Array[ConfiguracionJugadorPartido] = [config_jugador]
	pool_random_jugadores.append_array(get_pool_random_enemigos())
	
	crear_bracket(estado_actual, pool_random_jugadores)

func mostrar_partidos() -> void:
	# Mapeo de nombres legibles para cada estado del enum
	var nombres_estado := {
		Estado.CUARTOS: "Cuartos de Final",
		Estado.SEMIS: "Semifinales",
		Estado.FINAL: "Final"
	}
	
	print("====================================")
	print("       ESTADO DEL TORNEO            ")
	print("====================================")
	
	for estado in partidos.keys():
		var nombre_fase: String = nombres_estado.get(estado, "Fase Desconocida")
		var lista_partidos: Array = partidos[estado]
		
		print("\n--- %s (%d) ---" % [nombre_fase, lista_partidos.size()])
		
		if lista_partidos.is_empty():
			print("  (Sin partidos registrados)")
		else:
			for i in range(lista_partidos.size()):
				var partido = lista_partidos[i]
				print("  [%d] %s" % [i + 1, str(partido)])

func get_pool_random_enemigos() -> Array[ConfiguracionJugadorPartido]:
	var pool_jugadores = DatosJugadores.get_array_jugadores()
	pool_jugadores.erase(DatosJugadores.get_jugador(configuracion_jugador_seleccionado.jugador))
	pool_jugadores.shuffle()
	pool_jugadores = pool_jugadores.slice(0, 7)
	var pool_jugadores_configurados : Array[ConfiguracionJugadorPartido]= []
	for i in pool_jugadores.size():
		var configuracion_jugador_enemigo = ConfiguracionJugadorPartido.new()
		pool_jugadores_configurados.append(configuracion_jugador_enemigo.setup(pool_jugadores[i].nombre, "mano_magica"))#pool_jugadores[i].poderes[randi_range(0,1)]))
	
	return pool_jugadores_configurados
		
func crear_bracket(estado : Estado, pool_jugadores : Array[ConfiguracionJugadorPartido]) -> void:
	for i in range(pool_jugadores.size() / 2.0):
		var enfrentamiento = Enfrentamientos.new()
		enfrentamiento.set_jugador_local(pool_jugadores[i*2].jugador, pool_jugadores[i*2].poder)
		enfrentamiento.set_jugador_visitante(pool_jugadores[i*2 + 1].jugador, pool_jugadores[i*2 + 1].poder)
		partidos[estado].append(enfrentamiento)

func avanzar() -> void:
	if estado_actual < Estado.COMPLETADO:
		var partidos_actuales : Array = partidos[estado_actual]
		var ganadores : Array[ConfiguracionJugadorPartido] = []
		for partido_actual : Enfrentamientos in partidos_actuales:
			partido_actual.get_random_marcador()
			ganadores.append(partido_actual.get_ganador())
		estado_actual = estado_actual + 1 as Estado
		if estado_actual == Estado.COMPLETADO:
			ganador = ganadores[0]
		else:
			crear_bracket(estado_actual, ganadores)
