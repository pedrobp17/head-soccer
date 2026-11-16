extends Node
class_name EstadoJugador

signal peticion_transmision_estado( nuevo_estado: Jugador.Estado, datos : DatosEstadoJugador)

var animacion_jugador : AnimationPlayer = null
var jugador : Jugador = null
var comportamiento_ia : ComportamientoIA = null 
var datos_juego : DatosEstadoJugador = null
var nombre_estado : Jugador.Estado

func _ready() -> void:
	EventBus.reposicionar.connect(reset_posicion)

func setup( jugador_entrada : Jugador, animacion_entrada : AnimationPlayer, _comportamiento_ia : ComportamientoIA, _datos : DatosEstadoJugador) -> void:
	jugador = jugador_entrada
	animacion_jugador = animacion_entrada
	comportamiento_ia = _comportamiento_ia
	datos_juego = _datos
func movimiento_general(delta: float) -> void:
	if jugador.esquema_control == Jugador.ControlScheme.IA:
		comportamiento_ia.actualizar(delta)
	if not jugador.is_on_floor():
		jugador.velocity.y += GestorEstadisticas.GRAVEDAD_JUGADOR * delta

	# Handle jump.
	if accion_pulsada(KeyUtils.Accion.SALTO) and jugador.is_on_floor():
		jugador.velocity.y = jugador.estadisticas.get_velocidad_salto()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direccion: float = comportamiento_ia.direccion if jugador.esquema_control == Jugador.ControlScheme.IA else KeyUtils.get_input_vector(jugador.esquema_control)
	if direccion:
		jugador.velocity.x = direccion * jugador.estadisticas.get_estadistica("velocidad")
	else:
		jugador.velocity.x = 0.0 # Frenado inmediato para conservar una respuesta ?gil.

func accion_pulsada(accion: KeyUtils.Accion) -> bool:
	if jugador.esquema_control != Jugador.ControlScheme.IA:
		return KeyUtils.is_action_just_pressed(jugador.esquema_control, accion)
	match accion:
		KeyUtils.Accion.SALTO:
			return comportamiento_ia.saltar
		KeyUtils.Accion.PATADA:
			return comportamiento_ia.patear
	# Los poderes actuales no tienen implementacion; activarlos bloquearia a la IA.
	return false

func cambiar_estado(nuevo_estado : Jugador.Estado, datos : DatosEstadoJugador = DatosEstadoJugador.new()) -> void:
	peticion_transmision_estado.emit(nuevo_estado, datos)

func reset_posicion(_es_visitante: bool) -> void:
	cambiar_estado(Jugador.Estado.REINICIO, DatosEstadoJugador.build().set_es_visitante(_es_visitante).set_nombre_estado(nombre_estado))

func puede_recibir_daño() -> bool:
	return false
