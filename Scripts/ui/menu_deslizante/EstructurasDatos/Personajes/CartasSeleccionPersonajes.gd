extends Control

@export var duracion_animacion: float = 0.4

var es_actual: bool = false
var tween_transicion: Tween

@onready var fondo_no_actual: Control = %NotCurrent
@onready var fondo_actual: Control = %Current
@onready var nombre: Label = %Nombre


func set_mode(data, selected: bool, animar_seleccion: bool = false):
	nombre.text = NombresPersonajesHelper.get_nombre(data.name)
	fondo_no_actual.texture = data.normal_texture
	fondo_actual.texture = data.selected_texture

	fondo_no_actual.modulate.a = 1.0

	establecer_es_actual(selected, animar_seleccion)


func establecer_es_actual(
	p_es_actual: bool,
	animar: bool = true
) -> void:
	es_actual = p_es_actual

	if not animar:
		if tween_transicion and tween_transicion.is_valid():
			tween_transicion.kill()

		fondo_actual.modulate.a = 1.0 if p_es_actual else 0.0
		return

	if not is_visible_in_tree() and !es_actual:
		return

	if tween_transicion and tween_transicion.is_valid():
		tween_transicion.kill()

	tween_transicion = get_tree().create_tween()

	var alpha_objetivo: float = 1.0 if p_es_actual else 0.0

	tween_transicion.tween_property(
		fondo_actual,
		"modulate:a",
		alpha_objetivo,
		duracion_animacion * 2
	)
