class_name Enfrentamientos

var config_jugador_local := ConfiguracionJugadorPartido.new()
var config_jugador_visitante := ConfiguracionJugadorPartido.new().setup("AxelBlaze", "mano_magica")
var goles_local : int
var goles_visitante : int
var marcador_final : Array[int]
var ganador : String

func set_jugador_local(_jugador_local : String, _poder_local : String) -> void:
	config_jugador_local.setup(_jugador_local, _poder_local)

func set_jugador_visitante( _jugador_visitante : String, _poder_visitante : String) -> void:
	config_jugador_visitante.setup(_jugador_visitante, _poder_visitante)

func empate() -> bool:	
	return goles_local == goles_visitante
	
func aumentar_marcador( jugador_anotador : String) -> int:
	var indice_jugador_anotador
	if jugador_anotador == config_jugador_local.jugador:
		goles_local += 1
		indice_jugador_anotador = 0
	else:
		goles_visitante += 1
		indice_jugador_anotador = 1

	refresh_info_enfrentamiento()
	return indice_jugador_anotador

func goles_jugador( jugador_anotador : String) -> int:
	return goles_local if jugador_anotador == config_jugador_local.jugador else goles_visitante
	
func refresh_info_enfrentamiento() -> void:
	ganador = config_jugador_local.jugador if goles_local > goles_visitante else config_jugador_visitante.jugador
	marcador_final = [goles_local, goles_visitante]
