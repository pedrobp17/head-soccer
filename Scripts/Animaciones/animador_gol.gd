extends Control
class_name AnimadorGol

const RETARDO_ENTRADA = 0.15
const RETARDO_SALIDA = 0.3
const DURACION_MOVIMIENTO_MEDIO_PANTALLA = 1
const DURACION_MOVIMIENTO_ANIMACION = 0.5

enum Posicion {INICIO, MEDIO, FIN}

@onready var posicion_inicio_letras : Control = %PlaceholdersInicioLetras
@onready var posicion_medio_letras : Control = %PlaceholdersMedioLetras
@onready var posicion_fin_letras : Control = %PlaceholdersFinLetras
@onready var letras : Control = %ItemLetras
	
func _ready() -> void:
	posicion_medio_letras.hide()
	
func animar() -> void:
	var tween_entrada = create_tween()
	for i in range( letras.get_child_count() ):
		tween_con_intervalo(tween_entrada, i, Posicion.MEDIO, RETARDO_ENTRADA, DURACION_MOVIMIENTO_ANIMACION)
	await tween_entrada.finished
	
	await get_tree().create_timer(DURACION_MOVIMIENTO_MEDIO_PANTALLA).timeout

	var tween_salida = create_tween()
	for i in range( letras.get_child_count() ):
		tween_con_intervalo(tween_salida, i, Posicion.FIN, RETARDO_SALIDA, DURACION_MOVIMIENTO_ANIMACION)
	await  tween_salida.finished
	
	for i in range( letras.get_child_count()):
		letras.get_child(i).position = posicion_inicio_letras.get_child(i).position
	
	EventBus.fin_animacion_gol.emit()
	
func tween_con_intervalo( animacion_activa : Tween , indice : int, destino : Posicion, intervalo : float, duracion_movimiento : float) -> void:
	var letra_origen = letras.get_child(indice)
	var letra_destino = get_posicion_destino(destino).get_child(indice)
	animacion_activa.parallel().tween_property(
			letra_origen,
			"position",
			letra_destino.position,
			duracion_movimiento
		).set_delay(intervalo * indice)
		
	
func get_posicion_destino(destino : Posicion) -> Control:
	if destino == Posicion.INICIO:
		return posicion_inicio_letras
	elif destino == Posicion.MEDIO:
		return posicion_medio_letras
	else:
		return posicion_fin_letras
