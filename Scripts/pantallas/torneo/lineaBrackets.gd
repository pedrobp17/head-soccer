extends Control
class_name LineaBraquet

@export var textura_barra_vertical : Texture2D
@export var textura_barra_horizontal : Texture2D
@export var direccion_barra_horizontal_x : Direccion
@export var direccion_barra_vertical_y : Direccion
@export var fase : String

enum Direccion {H_LEFT, H_RIGHT, V_UP, V_DOWN}

const DURACION_ANIMACION = 2.0
const mapa_direcciones : Dictionary [Direccion, int] = {
	Direccion.V_UP : -1,
	Direccion.V_DOWN : 1,
	Direccion.H_LEFT : -1,
	Direccion.H_RIGHT : 1
}
@onready var barra_horizontal_cuartos: TextureProgressBar = $cuartos/barraHorizontal
@onready var barra_vertical_cuartos: TextureProgressBar = $cuartos/barraHorizontal/barraVertical
@onready var barra_horizontal_semis: TextureProgressBar = $semis/barraHorizontal
@onready var barra_vertical_semis: TextureProgressBar = $semis/barraHorizontal/barraVertical
var tiene_barra_vertical := false

func _ready() -> void:
	var barra_horizontal = barra_horizontal_cuartos if fase == "cuartos" else barra_horizontal_semis
	var barra_vertical = barra_vertical_cuartos if fase == "cuartos" else barra_vertical_semis
	
	if textura_barra_horizontal:
		barra_horizontal.show()
		barra_horizontal.value = 0.0
		barra_horizontal.texture_progress = textura_barra_horizontal
		barra_horizontal.scale = Vector2(mapa_direcciones[direccion_barra_horizontal_x], mapa_direcciones[direccion_barra_vertical_y])
		
	if textura_barra_vertical:
		barra_vertical.show()
		tiene_barra_vertical = true
		barra_vertical.value = 0.0
		barra_vertical.texture_progress = textura_barra_vertical

	
	
	
func animar() -> Tween:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var barra_horizontal = barra_horizontal_cuartos if fase == "cuartos" else barra_horizontal_semis
	var barra_vertical = barra_vertical_cuartos if fase == "cuartos" else barra_vertical_semis
	
	tween.tween_property(barra_horizontal, "value", 100, DURACION_ANIMACION)
	if tiene_barra_vertical:
		tween.tween_property(barra_vertical, "value", 100, DURACION_ANIMACION)
	return tween

func set_max() -> void:
	var barra_horizontal = barra_horizontal_cuartos if fase == "cuartos" else barra_horizontal_semis
	var barra_vertical = barra_vertical_cuartos if fase == "cuartos" else barra_vertical_semis
	barra_horizontal.value = 100
	barra_vertical.value = 100
	
