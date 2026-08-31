extends Node
class_name GestorEstadisticas

var estadisticas_normales : Dictionary = {}
var estadisticas_modificadas : Dictionary = {}

func inicializar( estadisticas_jugador : Dictionary ) -> void:
	estadisticas_normales = estadisticas_jugador.duplicate()
	
func modificar( estadistica : String, modificacion : int) -> void:
	if not estadisticas_modificadas.has(estadistica):
		estadisticas_modificadas[estadistica] = 0
	estadisticas_modificadas[estadistica] = modificacion
	
func get_estadistica( estadistica : String) -> int:
	if estadisticas_modificadas.has(estadistica):
		return estadisticas_modificadas[estadistica]
	return estadisticas_normales[estadistica]
