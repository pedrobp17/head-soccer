extends PanelContainer
class_name ElementoMenuCarrusel

@export var identificador: int = 0
@export var numero_placeholder : int
@export var duracion_animacion: float = 0.5
@export var modo_juego: String = "1VS1"
@export var textura_modo_juego: Texture2D
@export var textura_modo_juego_actual: Texture2D

var es_actual: bool = false

@onready var fondo_no_actual: Control = %NotCurrent
@onready var fondo_actual: Control = %Current
@onready var nombre: Label = %Nombre
@onready var textura_rect: TextureRect = %TextureRect

func _ready() -> void:
	establecer_es_actual(es_actual)
	nombre.text = modo_juego

	if textura_modo_juego and fondo_no_actual:
		fondo_no_actual.texture = textura_modo_juego
	
	if textura_modo_juego_actual and fondo_actual:
		fondo_actual.texture = textura_modo_juego_actual

func establecer_es_actual(p_es_actual: bool) -> void:
	es_actual = p_es_actual
	
	if not is_visible_in_tree():
		return
	
	var animacion = get_tree().create_tween()
	
	animacion.parallel().tween_property(fondo_no_actual, "modulate:a", int(not p_es_actual), duracion_animacion * 2)
	animacion.parallel().tween_property(fondo_actual, "modulate:a", int(p_es_actual), duracion_animacion * 2)
