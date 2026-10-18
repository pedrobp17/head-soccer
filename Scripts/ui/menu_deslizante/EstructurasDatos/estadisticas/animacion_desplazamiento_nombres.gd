extends Panel
class_name AnimacionDesplazamientoNombres

const MAPA_DIRECCIONES: Dictionary = {
	"derecha": 0,
	"centro": 1,
	"izquierda": 2
}
const DURACION_ANIMACION := 0.4

@onready var placeholders: Array[Label] = [%Derecha, %Centro, %Izquierda]
@onready var nombres_intercambiados: Array[Label] = [%Entrante, %Saliente]
@onready var nombre: Label = %Nombre

# [0] = nombre actual (el que entra), [1] = nombre anterior (el que sale)
var nombre_jugador: Array[String] = ["", ""]
var animando: bool = false


func _ready() -> void:
	actualizar_placeholder()
	actualizar_nombres_intercambio()

func set_nombre(jugador: String) -> void:
	actualizar_nombres(jugador)
	nombre.text = nombre_jugador[0]


func girar_derecha() -> void:
	if animando:
		return
	set_nombres_intercambios("derecha")
	girar("izquierda")

func girar_izquierda() -> void:
	if animando:
		return
	set_nombres_intercambios("izquierda")
	girar("derecha")


func set_nombres_intercambios(posicion_entrante: String) -> void:
	var entrante := nombres_intercambiados[0]
	var saliente := nombres_intercambiados[1]

	saliente.text = nombre_jugador[1]
	copiar_propiedades(nombre, saliente)

	entrante.text = nombre_jugador[0]
	copiar_propiedades(placeholders[MAPA_DIRECCIONES[posicion_entrante]], entrante)

	entrante.show()
	saliente.show()
	nombre.hide()


func girar(posicion_saliente: String) -> void:
	animando = true
	var entrante := nombres_intercambiados[0]
	var saliente := nombres_intercambiados[1]
	var centro := placeholders[MAPA_DIRECCIONES["centro"]]
	var destino_saliente := placeholders[MAPA_DIRECCIONES[posicion_saliente]]

	var tween := create_tween().set_parallel(true)
	tween.tween_property(entrante, "global_position", centro.global_position, DURACION_ANIMACION)
	tween.tween_property(entrante, "scale", centro.scale, DURACION_ANIMACION)
	tween.tween_property(saliente, "global_position", destino_saliente.global_position, DURACION_ANIMACION)
	tween.tween_property(saliente, "scale", destino_saliente.scale, DURACION_ANIMACION)

	await tween.finished
	finalizar_animacion()
	EventBus.fin_animacion_nombre.emit()

func finalizar_animacion() -> void:
	actualizar_nombres_intercambio()
	nombre.text = nombre_jugador[0]
	nombre.show()
	animando = false


func actualizar_placeholder() -> void:
	for label in placeholders:
		label.hide()


func actualizar_nombres_intercambio() -> void:
	for label in nombres_intercambiados:
		label.hide()


func copiar_propiedades(origen: Label, destino: Label) -> void:
	destino.size = origen.size
	destino.pivot_offset = origen.pivot_offset
	destino.global_position = origen.global_position
	destino.scale = origen.scale
	destino.horizontal_alignment = origen.horizontal_alignment


func actualizar_nombres(jugador: String) -> void:
	nombre_jugador[1] = nombre_jugador[0]
	nombre_jugador[0] = jugador
