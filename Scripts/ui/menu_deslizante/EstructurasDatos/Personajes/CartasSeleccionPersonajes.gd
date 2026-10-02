extends Control

@export var duracion_animacion: float = 0.4

var es_actual: bool = false
var tween_transicion: Tween

@onready var selected: Control = $Selected
@onready var fondo_no_actual: Control = %NotCurrent
@onready var fondo_actual: Control = %Current
@onready var nombre: Label = %Nombre

var is_seleccionado = false

func set_mode(data, _selected: bool, animar_seleccion: bool = false, p_is_seleccionado: bool = false):
	nombre.text = NombresPersonajesHelper.get_nombre(data.name)
	fondo_no_actual.texture = data.normal_texture
	fondo_actual.texture = data.selected_texture
	selected.texture = data.normal_seleccionado_texture
	

	establecer_seleccionado(p_is_seleccionado)
	

	establecer_es_actual(_selected, animar_seleccion)


func establecer_seleccionado(p_is_seleccionado: bool) -> void:
	is_seleccionado = p_is_seleccionado
	if is_seleccionado:
		set_selected()
	else:
		set_current()


func establecer_es_actual(p_es_actual: bool, animar: bool = true) -> void:
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

func set_selected() -> void:
	selected.modulate.a = 1.0
	fondo_no_actual.modulate.a = 0.0
	
func set_current() -> void:
	fondo_no_actual.modulate.a = 1.0
	selected.modulate.a = 0.0
