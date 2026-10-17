class_name ProgresoGlobal
extends Resource

enum Modos {VERSUS, SURVIVAL, ONLINE, ARCADE, TORNEO, LIGA, MUNDIAL, PELEA}

var ultimo_modo_jugado : Modos = Modos.VERSUS
var ultimo_jugador_seleccionado : String = ""
var ultimo_poder_jugador_seleccionado : String = ""
var indice_ultimo_jugador_seleccionado : int = 0

func serialize() -> Dictionary:
	return {
		"ultimo_modo_jugado": Modos.keys()[ultimo_modo_jugado],
		"ultimo_jugador_seleccionado": ultimo_jugador_seleccionado,
		"indice_ultimo_jugador_seleccionado" : indice_ultimo_jugador_seleccionado,
		"ultimo_poder_jugador_seleccionado": ultimo_poder_jugador_seleccionado
	}


static func deserialize(datos: Dictionary) -> ProgresoGlobal:
	var progreso := ProgresoGlobal.new()

	var nombre_modo: String = str(datos.get("ultimo_modo_jugado", "")).to_upper()
	if Modos.has(nombre_modo):
		progreso.ultimo_modo_jugado = Modos[nombre_modo]
	elif nombre_modo != "":
		push_warning("Modo de juego desconocido en el JSON: " + nombre_modo)

	progreso.ultimo_jugador_seleccionado = datos.get("ultimo_jugador_seleccionado", "")
	progreso.indice_ultimo_jugador_seleccionado = datos.get( "indice_ultimo_jugador_seleccionado", "0")
	progreso.ultimo_poder_jugador_seleccionado = datos.get("ultimo_poder_jugador_seleccionado", "")
	return progreso
