extends Node
class_name EstadoJugador

signal peticion_transmision_estado( nuevo_estado: Jugador.Estado, datos : DatosEstadoJugador)

var animacion_jugador : AnimationPlayer = null
var jugador : Jugador = null
var comportamiento_ia : ComportamientoIA = null 
var datos_juego : DatosEstadoJugador = null

func _ready() -> void:
	EventBus.reposicionar.connect(reset_posicion)

func setup( jugador_entrada : Jugador, animacion_entrada : AnimationPlayer, _comportamiento_ia : ComportamientoIA, _datos : DatosEstadoJugador) -> void:
	jugador = jugador_entrada
	animacion_jugador = animacion_entrada
	comportamiento_ia = _comportamiento_ia
	datos_juego = _datos

func movimiento_general(delta: float) -> void:
	if not jugador.is_on_floor():
		jugador.velocity += jugador.get_gravity() * delta

	# Handle jump.
	if KeyUtils.is_action_just_pressed( jugador.esquema_control, KeyUtils.Accion.SALTO ) and jugador.is_on_floor():
		jugador.velocity.y = jugador.estadisticas.get_estadistica("salto")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direccion :=  KeyUtils.get_input_vector(jugador.esquema_control)
	if direccion:
		jugador.velocity.x = direccion * jugador.estadisticas.get_estadistica("velocidad")
	else:
		jugador.velocity.x = move_toward(jugador.velocity.x, 0, jugador.estadisticas.get_estadistica("velocidad"))
	
	
func cambiar_estado(nuevo_estado : Jugador.Estado, datos : DatosEstadoJugador = DatosEstadoJugador.new()) -> void:
	peticion_transmision_estado.emit(nuevo_estado, datos)

func reset_posicion(_jugador : String) -> void:
	cambiar_estado(Jugador.Estado.REINICIO, DatosEstadoJugador.build().set_jugador_anotador(_jugador))

func puede_recibir_daño() -> bool:
	return false
