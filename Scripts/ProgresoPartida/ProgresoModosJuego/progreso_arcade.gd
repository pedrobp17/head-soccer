extends RefCounted
class_name ProgresoArcade

const NIVELES_POR_JUGADOR = 2

var progreso_por_jugador : Dictionary = {}


static func deserialize(datos : Dictionary) -> ProgresoArcade:
	var progreso := ProgresoArcade.new()
	progreso.progreso_por_jugador = datos
	return progreso

func serialize() -> Dictionary:
	return progreso_por_jugador


func asegurar_jugador(jugador : String) -> void:
	if progreso_por_jugador.has(jugador):
		return
	progreso_por_jugador[jugador] = crear_progreso_jugador()

static func crear_progreso_jugador() -> Dictionary:
	var progreso := {}
	for isla in PantallaArcade.jugadores_islas:
		var jugadores := {}
		for rival in PantallaArcade.jugadores_islas[isla]:
			for nivel in NIVELES_POR_JUGADOR:
				jugadores[clave_nivel(rival, nivel)] = false
		progreso[nombre_isla(isla)] = {
			"desbloqueada": true,
			"jugadores": jugadores
		}
	return progreso

static func clave_nivel(rival : String, nivel : int) -> String:
	return "%s_%d" % [rival, nivel]

static func nombre_isla(isla : PantallaArcade.Islas) -> String:
	return PantallaArcade.Islas.keys()[isla]


func get_islas_desbloqueadas(jugador : String) -> Array[PantallaArcade.Islas]:
	asegurar_jugador(jugador)
	var resultado : Array[PantallaArcade.Islas] = []
	for isla in PantallaArcade.jugadores_islas:
		if progreso_por_jugador[jugador][nombre_isla(isla)]["desbloqueada"]:
			resultado.append(isla)
	return resultado

func desbloquear_isla(jugador : String, isla : PantallaArcade.Islas) -> void:
	asegurar_jugador(jugador)
	progreso_por_jugador[jugador][nombre_isla(isla)]["desbloqueada"] = true

func esta_vencido(jugador : String, isla : PantallaArcade.Islas, rival : String, nivel : int) -> bool:
	asegurar_jugador(jugador)
	return progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"].get(clave_nivel(rival, nivel), false)

func set_vencido(jugador : String, isla : PantallaArcade.Islas, rival : String, nivel : int, valor : bool = true) -> void:
	asegurar_jugador(jugador)
	progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"][clave_nivel(rival, nivel)] = valor

func isla_completada(jugador : String, isla : PantallaArcade.Islas) -> bool:
	asegurar_jugador(jugador)
	return not false in progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"].values()

func get_niveles_vencidos(jugador : String, isla : PantallaArcade.Islas) -> int:
	asegurar_jugador(jugador)
	return progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"].values().count(true)

func get_niveles_totales(isla : PantallaArcade.Islas) -> int:
	return PantallaArcade.jugadores_islas[isla].size() * NIVELES_POR_JUGADOR
	
