extends Control

@export var duracion_animacion: float = 0.4

var es_actual: bool = false
var tween_transicion: Tween
var is_seleccionado = false
var id_personaje: String = ""

@onready var selected: Control = $Selected
@onready var fondo_no_actual: Control = %NotCurrent
@onready var fondo_actual: Control = %Current
@onready var nombre: Label = %Nombre
@onready var not_current_bloq: TextureRect = %NotCurrentBloq
@onready var current_bloq: TextureRect = %CurrentBloq


func set_mode(data, central: bool, animar_seleccion: bool = false, p_is_seleccionado: bool = false):
	id_personaje = data.name
	
	nombre.text = NombresPersonajesHelper.get_nombre_normal_to_salto_linea(data.name)
	fondo_no_actual.texture = data.normal_texture
	fondo_actual.texture = data.selected_texture
	selected.texture = data.normal_seleccionado_texture
	not_current_bloq.texture = data.normal_bloqueado_texture
	current_bloq.texture = data.selected_bloqueado_texture

	establecer_seleccionado(p_is_seleccionado)
	establecer_es_actual(central, animar_seleccion)


func establecer_seleccionado(p_is_seleccionado: bool) -> void:
	is_seleccionado = p_is_seleccionado
	if is_seleccionado:
		setcentral()
	else:
		set_current()


func establecer_es_actual(p_es_actual: bool, animar: bool = true) -> void:
	es_actual = p_es_actual

	var esta_desbloqueado = ProgresoPartida.is_personaje_desbloqueado(id_personaje)
	
	var nodo_objetivo = fondo_actual if esta_desbloqueado else current_bloq
	var nodo_inactivo = current_bloq if esta_desbloqueado else fondo_actual
	nodo_inactivo.modulate.a = 0.0
	
	var fondo_base_activo: Control
	if is_seleccionado:
		fondo_base_activo = selected
	else:
		fondo_base_activo = fondo_no_actual if esta_desbloqueado else not_current_bloq

	var alpha_objetivo: float = 1.0 if p_es_actual else 0.0
	var alpha_base: float = 0.0 if p_es_actual else 1.0

	if not animar:
		if tween_transicion and tween_transicion.is_valid():
			tween_transicion.kill()
		nodo_objetivo.modulate.a = alpha_objetivo
		fondo_base_activo.modulate.a = alpha_base
		return

	if not is_visible_in_tree() and !es_actual:
		return

	if tween_transicion and tween_transicion.is_valid():
		tween_transicion.kill()

	tween_transicion = get_tree().create_tween()
	tween_transicion.set_parallel(true)
	
	tween_transicion.tween_property(
		nodo_objetivo,
		"modulate:a",
		alpha_objetivo,
		duracion_animacion * 2
	)
	
	tween_transicion.tween_property(
		fondo_base_activo,
		"modulate:a",
		alpha_base,
		duracion_animacion * 2
	)


func setcentral() -> void:
	selected.modulate.a = 1.0
	fondo_no_actual.modulate.a = 0.0
	not_current_bloq.modulate.a = 0.0
	

func set_current() -> void:
	if ProgresoPartida.is_personaje_desbloqueado(id_personaje):
		fondo_no_actual.modulate.a = 1.0
		selected.modulate.a = 0.0
		not_current_bloq.modulate.a = 0.0
	else:
		fondo_no_actual.modulate.a = 0.0
		selected.modulate.a = 0.0
		not_current_bloq.modulate.a = 1.0
