extends Node
class_name AnimacionEnfrentamiento

const NUM_JUGADORES_ENFRENTAMIENTO := 2 
const DURACION_ANIMACION_ENTRADA := 0.8
const DURACION_ANIMACION_ESCALADO := 0.5
const DURACION_PARPADEO := 0.8

@onready var back: Sprite2D = %Back
@onready var rayo: Sprite2D = %rayo
@onready var animacion_back: AnimationPlayer = %AnimacionBack 
@onready var animacion_rayo: AnimationPlayer = %Rayo
@onready var posiciones_medio : Array[Node2D] = [%posicionJugador1, %posicionJugador2]
@onready var posiciones_inicial : Array[Node2D] = [%centro1, %centro2]
@onready var posiciones_final : Array[Node2D] = [%Final1, %Final2]
@onready var cabezas_jugadores : Array[Sprite2D] = [%Personaje1, %Personaje2]
@onready var frase: Label = %Label

signal jugador_quiere_iniciar

var esperando_espacio : bool

func _ready() -> void:
	for i in NUM_JUGADORES_ENFRENTAMIENTO:
		#var jugador = ControladorPartido.enfrentamiento.config_jugador_local.jugador if i == 0 else ControladorPartido.enfrentamiento.config_jugador_visitante.jugador 
		cabezas_jugadores[i].texture = CabezasHelper.get_cabeza("ArtieMishman")#jugador)
	
	back.scale.y = 0
	frase.hide()
	rayo.hide()
	esperando_espacio = false
	
func animar() -> void:
	var tween = create_tween()
	animacion_back.play("enfrentamiento")
	tween.tween_property(back, "scale:y",  2, DURACION_ANIMACION_ESCALADO)
	await  tween.finished
	
	var tween_entrada_personajes = create_tween()
	
	for i in NUM_JUGADORES_ENFRENTAMIENTO:
		tween_entrada_personajes.parallel().tween_property(cabezas_jugadores[i], "global_position", posiciones_inicial[i].global_position, DURACION_ANIMACION_ENTRADA)
	await tween_entrada_personajes.finished
	
	rayo.show()
	animacion_rayo.play("Intro")
	animacion_rayo.queue("Loop")
	
	var tween_posicion_personajes = create_tween()
	for i in NUM_JUGADORES_ENFRENTAMIENTO:
		tween_posicion_personajes.parallel().tween_property(cabezas_jugadores[i], "global_position", posiciones_medio[i].global_position, DURACION_ANIMACION_ENTRADA/2.0)
	await tween_posicion_personajes.finished
	esperando_espacio = true
	
	var tween_parpadeo = create_tween().set_loops()
	tween_parpadeo.tween_callback(func(): frase.visible = not frase.visible).set_delay(0.4)
	await jugador_quiere_iniciar
	frase.hide()
	tween_parpadeo.kill()
	
	animacion_rayo.play("Outro")
	var tween_salida = create_tween()
	tween_salida.parallel().tween_property(back, "modulate:a",  0.0, DURACION_ANIMACION_ESCALADO/2.0)
	for i in NUM_JUGADORES_ENFRENTAMIENTO:
		tween_salida.parallel().tween_property(cabezas_jugadores[i], "global_position", posiciones_final[i].global_position, DURACION_ANIMACION_ENTRADA/2.0)
	await tween_salida.finished
	EventBus.fin_animacion_vs.emit()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") and esperando_espacio:
		esperando_espacio = false
		jugador_quiere_iniciar.emit()
	
	
	
