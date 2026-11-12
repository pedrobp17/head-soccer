class_name Enfrentamientos

var config_jugador_local := ConfiguracionJugadorPartido.new()
var config_jugador_visitante := ConfiguracionJugadorPartido.new().setup("AxelBlaze", "mano_magica")
var goles_local : int
var goles_visitante : int
var marcador_final : Array
var ganador : String = ""

func set_jugador_local(_jugador_local : String, _poder_local : String) -> void:
	config_jugador_local.setup(_jugador_local, _poder_local)

func set_jugador_visitante( _jugador_visitante : String, _poder_visitante : String) -> void:
	config_jugador_visitante.setup(_jugador_visitante, _poder_visitante)

func empate() -> bool:	
	return goles_local == goles_visitante
	
func aumentar_marcador(es_visitante: bool) -> void:
	if es_visitante:
		goles_visitante += 1
	else:
		goles_local += 1
	refresh_info_enfrentamiento()

func goles_jugador(es_visitante: bool) -> int:
	return goles_visitante if es_visitante else goles_local

func gana_local() -> bool:
	return goles_local > goles_visitante
	
func refresh_info_enfrentamiento() -> void:
	ganador = config_jugador_local.jugador if gana_local() else config_jugador_visitante.jugador
	marcador_final = [goles_local, goles_visitante]

func reiniciar_resultado() -> void:
	goles_local = 0
	goles_visitante = 0
	marcador_final = []
	ganador = ""
	
func get_random_marcador() -> void:
	while empate():
		goles_local = randi_range(0,7)
		goles_visitante = randi_range(0,7)
	refresh_info_enfrentamiento()
	
func get_ganador() -> ConfiguracionJugadorPartido:
	if gana_local():
		return config_jugador_local
	return config_jugador_visitante

func serialize() -> Dictionary:
	return {
		"local": config_jugador_local.serialize(),
		"visitante": config_jugador_visitante.serialize(),
		"goles_local": goles_local,
		"goles_visitante": goles_visitante,
		"ganador" : ganador,
		"marcador_final" : marcador_final

}

static func deserialize(data: Dictionary) -> Enfrentamientos:
	var enfrentamiento := Enfrentamientos.new()
	enfrentamiento.set_jugador_local(data["local"]["jugador"], data["local"]["poder"])
	enfrentamiento.set_jugador_visitante(data["visitante"]["jugador"], data["visitante"]["poder"])
	enfrentamiento.goles_local = int(data["goles_local"])
	enfrentamiento.goles_visitante = int(data["goles_visitante"])
	enfrentamiento.ganador = data["ganador"]
	enfrentamiento.marcador_final = data["marcador_final"]
	return enfrentamiento
