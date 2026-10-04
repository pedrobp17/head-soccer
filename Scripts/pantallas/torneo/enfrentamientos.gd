class_name Enfrentamientos

var jugador_local : String
var poder_local : String
var jugador_visitante : String = "AxelBlaze"
var poder_visitante : String = "mano_magica"
var goles_local : int
var goles_visitante : int
var marcador_final : Array[int]
var ganador : String

func set_jugador_local(_jugador_local : String, _poder_local : String) -> void:
	jugador_local =  _jugador_local
	poder_local = _poder_local

func set_jugador_visitante( _jugador_visitante : String, _poder_visitante : String) -> void:
	jugador_visitante =  _jugador_visitante
	poder_visitante = _poder_visitante

func empate() -> bool:	
	return goles_local == goles_visitante
	
func aumentar_marcador( jugador_anotador : String) -> int:
	var indice_jugador_anotador
	if jugador_anotador == jugador_local:
		goles_local += 1
		indice_jugador_anotador = 0
	else:
		goles_visitante += 1
		indice_jugador_anotador = 1

	refresh_info_enfrentamiento()
	return indice_jugador_anotador

func goles_jugador( jugador_anotador : String) -> int:
	return goles_local if jugador_anotador == jugador_local else goles_visitante
	
func refresh_info_enfrentamiento() -> void:
	ganador = jugador_local if goles_local > goles_visitante else jugador_visitante
	marcador_final = [goles_local, goles_visitante]
