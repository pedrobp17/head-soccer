extends Panel
class_name ErrorModosJuego

signal boton_pulsado

const COLOR_SELECCION := Color("ffff49")
const COLOR_NO_SELECCION := Color("00a0fb")
const DURACION_ANIMACION := 0.4

@onready var jugador: RichTextLabel = %RichTextLabel
@onready var botones: Array[Panel] = [%volver, %Nuevo]
@onready var error: Panel = %Error

var estilos: Array[StyleBoxFlat] = []
var foco: bool = false
var animando: bool = false
var indice_boton_actual: int = 1


func _ready() -> void:
	jugador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modulate.a = 0.0
	foco = false
	animando = false
	indice_boton_actual = 1
	error.scale = Vector2.ZERO

	for boton in botones:
		var estilo := boton.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		boton.add_theme_stylebox_override("panel", estilo)
		estilo.bg_color = COLOR_NO_SELECCION
		estilos.append(estilo)

	estilos[indice_boton_actual].bg_color = COLOR_SELECCION
	
func mostrar() -> void:
	jugador.text = ProgresoPartida.progreso_general.get_jugador_torneo_actual()
	cambiar_foco(true)
	animando = true
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, DURACION_ANIMACION)
	tween.tween_property(error, "scale", Vector2.ONE, DURACION_ANIMACION).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	animando = false


func ocultar() -> void:
	animando = true
	cambiar_foco(false)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, DURACION_ANIMACION)
	tween.tween_property(error, "scale", Vector2.ZERO, DURACION_ANIMACION).set_trans(Tween.TRANS_BOUNCE)
	await tween.finished
	animando = false
	seleccionar_boton(1)

func cambiar_foco( tiene_foco : bool ) -> void:
	foco = tiene_foco
	get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not foco or animando:
		return

	if event.is_action_pressed("ui_left") and indice_boton_actual != 0:
		seleccionar_boton(0)
	if event.is_action_pressed("ui_right") and indice_boton_actual != 1:
		seleccionar_boton(1)
	if event.is_action_pressed("ui_accept"):
		ocultar()
		boton_pulsado.emit()
		
func seleccionar_boton(nuevo_indice: int) -> void:
	animando = true
	var anterior := indice_boton_actual
	indice_boton_actual = nuevo_indice

	var tween := create_tween().set_parallel(true)
	tween.tween_property(estilos[nuevo_indice], "bg_color", COLOR_SELECCION, DURACION_ANIMACION)
	tween.tween_property(estilos[anterior], "bg_color", COLOR_NO_SELECCION, DURACION_ANIMACION)
	await tween.finished
	animando = false
