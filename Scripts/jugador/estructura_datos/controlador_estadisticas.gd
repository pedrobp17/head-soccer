extends Node
class_name GestorEstadisticas

var base := 5.0
var salto_siguiente_nivel : Dictionary = {
	"velocidad": 300.0,
	"salto": -450.0,
	"golpe": 60.0,
	"power": 5.0,
	"aguante": 5.0,
	"vida": 10.0
}

var constantes : Dictionary = {
	"velocidad": 300.0,
	"salto": -450.0,
	"golpe": 60.0,
	"power": 100.0,
	"aguante": 5.0,
	"vida": 100.0
}

var estadisticas_normales : Dictionary = {}
var estadisticas_modificadas : Dictionary = {}

func inicializar( estadisticas_jugador : Dictionary ) -> void:
	estadisticas_normales = estadisticas_jugador.duplicate()
	
func modificar( estadistica : String, modificacion : float) -> void:
	estadisticas_modificadas[estadistica] = get_estadistica(estadistica) + modificacion
	
func get_estadistica( estadistica : String) -> float:
	if estadisticas_modificadas.has(estadistica):
		return estadisticas_modificadas[estadistica]
	return (estadisticas_normales[estadistica] - base) * salto_siguiente_nivel[estadistica] + constantes[estadistica]

func reset_estadistica( estadistica : String) ->void:
	if estadisticas_modificadas.has(estadistica):
		estadisticas_modificadas.erase(estadistica)
	
