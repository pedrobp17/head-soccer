extends Control

@export var duracion_animacion: float = 0.4

var es_actual: bool = false
var tween_transicion: Tween

@onready var fondo_no_actual: Panel = %NotCurrent
@onready var fondo_actual: Panel = %Current
@onready var nombre: Label = %Nombre
@onready var dibujo: TextureRect = %Dibujo

func set_mode(data, selected: bool, animar_seleccion: bool = false) -> void:
	nombre.text = data.name
	dibujo.texture = data.normal_texture
	fondo_no_actual.modulate.a = 1.0
	
	establecer_es_actual(selected, animar_seleccion)


func establecer_es_actual(p_es_actual: bool, animar: bool = true) -> void:
	es_actual = p_es_actual
	
	if p_es_actual:
		nombre.add_theme_color_override("font_color", Color("05316f"))
	else:
		nombre.add_theme_color_override("font_color", Color.WHITE)
	
	if tween_transicion and tween_transicion.is_valid():
		tween_transicion.kill()
	
	var alpha_objetivo: float = 1.0 if p_es_actual else 0.0
	
	
	if not animar:
		fondo_actual.modulate.a = alpha_objetivo
		return
	
	if not is_visible_in_tree():
		fondo_actual.modulate.a = alpha_objetivo
		return
	
	tween_transicion = get_tree().create_tween()
	tween_transicion.tween_property(
		fondo_actual,
		"modulate:a",
		alpha_objetivo,
		duracion_animacion * 2
	)
