extends Node
class_name GestorEstadisticas

const BASE: float = 5.0
const ALTURA_CAPSULA_REFERENCIA: float = 114.2 # Media de las 10 capsulas con altura > 0.
const FACTOR_ALTURA_SALTO: float = 1.2733875
const ALTURA_SALTO_BASE: float = (165.0 - ALTURA_CAPSULA_REFERENCIA) * FACTOR_ALTURA_SALTO
const ALTURA_SALTO_MINIMA: float = 12.0 * FACTOR_ALTURA_SALTO
# Conserva la gravedad original al reducir la altura del salto.
const GRAVEDAD_JUGADOR: float = 2.0 * 220.0 / (0.35 * 0.35)
# Unidades: velocidad px/s, salto px, power segundos, aguante px de retroceso.
# Las modificaciones se expresan en estas unidades, no en puntos de la ficha.
const LIMITES: Dictionary = {
	"velocidad": Vector2(360.0, 640.0),
	"salto": Vector2(ALTURA_SALTO_MINIMA, (290.0 - ALTURA_CAPSULA_REFERENCIA) * FACTOR_ALTURA_SALTO),
	"power": Vector2(14.0, 26.0),
	"aguante": Vector2(120.0, 300.0),
	"golpe": Vector2(0.65, 1.35)
}
var salto_siguiente_nivel: Dictionary = {
	"velocidad": 28.0,
	"salto": 25.0 * FACTOR_ALTURA_SALTO,
	"golpe": 0.07,
	"power": -1.2,
	"aguante": -18.0,
	"vida": 10.0
}

var constantes: Dictionary = {
	"velocidad": 500.0,
	"salto": ALTURA_SALTO_BASE,
	"golpe": 1.0,
	"power": 20.0,
	"aguante": 210.0,
	"vida": 100.0
}

var estadisticas_normales: Dictionary = {}
var estadisticas_modificadas: Dictionary = {}

func inicializar(estadisticas_jugador: Dictionary) -> void:
	estadisticas_normales = estadisticas_jugador.duplicate()
	estadisticas_modificadas.clear()
	
func modificar(estadistica: String, modificacion: float) -> void:
	estadisticas_modificadas[estadistica] = get_estadistica(estadistica) + modificacion
	
func get_estadistica(estadistica: String) -> float:
	var puntuacion: float = clampf(float(estadisticas_normales[estadistica]), 0.0, 10.0)
	var valor: float = (puntuacion - BASE) * salto_siguiente_nivel[estadistica] + constantes[estadistica]
	# Desplazamiento calibrado con la capsula media, ajustado mediante FACTOR_ALTURA_SALTO.
	# Por debajo de 4, conserva un desplazamiento minimo positivo.
	if estadistica == "salto" and puntuacion < 4.0:
		valor = lerpf(ALTURA_SALTO_MINIMA, (140.0 - ALTURA_CAPSULA_REFERENCIA) * FACTOR_ALTURA_SALTO, puntuacion / 4.0)
	if estadisticas_modificadas.has(estadistica):
		valor = estadisticas_modificadas[estadistica]
	if LIMITES.has(estadistica):
		var limites: Vector2 = LIMITES[estadistica]
		return clampf(valor, limites.x, limites.y)
	return valor

func get_velocidad_salto() -> float:
	return -sqrt(2.0 * GRAVEDAD_JUGADOR * get_estadistica("salto"))

func reset_estadistica(estadistica: String) -> void:
	if estadisticas_modificadas.has(estadistica):
		estadisticas_modificadas.erase(estadistica)
	
func get_estadisticas_normalizadas_con_nombre():
	var estadisticas_normallizadas_con_nombre: Array = []
	for i in estadisticas_normales.size():
		estadisticas_normallizadas_con_nombre.append(transformacion_estadistica_array(i))
	return estadisticas_normallizadas_con_nombre

func transformacion_estadistica_array(indice: int) -> Array:
	var estadistica = estadisticas_normales.keys()[indice]
	var array = [estadistica, estadisticas_normales[estadistica]]
	return array
