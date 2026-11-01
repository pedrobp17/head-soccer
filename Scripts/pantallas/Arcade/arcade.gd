extends Pantallas
class_name PantallaArcade

enum Islas {RAIMON, MARYTIMES, OCCULT, ROYALACADEMY, WILD, BRAIN, ZEUS, GENESIS, NONE}

const mapa_direcciones : Dictionary = {
	KEY_LEFT : 0,
	KEY_RIGHT : 1,
	KEY_UP : 2,
	KEY_DOWN : 3
}
const vecinos : Dictionary = {
	Islas.RAIMON : [Islas.NONE, Islas.NONE, Islas.MARYTIMES, Islas.OCCULT],
	Islas.MARYTIMES : [Islas.NONE, Islas.ROYALACADEMY, Islas.NONE, Islas.RAIMON],
	Islas.OCCULT : [Islas.NONE, Islas.WILD, Islas.RAIMON, Islas.NONE],
	Islas.ROYALACADEMY : [Islas.MARYTIMES, Islas.BRAIN, Islas.NONE, Islas.NONE],
	Islas.WILD : [Islas.OCCULT, Islas.NONE, Islas.GENESIS, Islas.NONE],
	Islas.BRAIN : [Islas.ROYALACADEMY, Islas.NONE, Islas.NONE, Islas.GENESIS],
	Islas.ZEUS : [Islas.GENESIS, Islas.NONE, Islas.NONE, Islas.NONE],
	Islas.GENESIS : [Islas.NONE, Islas.ZEUS, Islas.BRAIN, Islas.WILD],
}

@onready var indicadores : Array[IndicadorIsla] = [%indicadorIsla1, %indicadorIsla2, %indicadorIsla3, %indicadorIsla4, %indicadorIsla5, %indicadorIsla6, %indicadorIsla7, %indicadorIsla8 ]

var isla_actual : Islas
var islas_desbloqueadas : Array[Islas] = [Islas.RAIMON, Islas.MARYTIMES, Islas.OCCULT]

func _ready() -> void:
	refresh_islas_desbloqueadas()
	set_seleccionado(Islas.RAIMON, Islas.NONE)
	
func refresh_islas_desbloqueadas() -> void:
	for isla in islas_desbloqueadas:
		indicadores[isla].set_desbloqueado()

func set_seleccionado(isla_seleccionada : Islas, isla_anterior : Islas) -> void:
	if isla_anterior != Islas.NONE:
		indicadores[isla_anterior].set_desbloqueado(true)
	isla_actual = isla_seleccionada
	indicadores[isla_seleccionada].set_actual()
	
func get_vecino( _direccion : Key ) -> Islas:
	if mapa_direcciones.has(_direccion):
		return vecinos[isla_actual][mapa_direcciones[_direccion]]
	return Islas.NONE
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		pass
		
	if event is InputEventKey and event.pressed:
		var vecino = get_vecino(event.keycode)
		if vecino == Islas.NONE or !es_valido(vecino):
			return
		set_seleccionado(vecino, isla_actual)

func es_valido( isla : Islas ) -> bool:
	return isla in islas_desbloqueadas
