extends Pantallas
class_name Campo

@onready var fin_timer: Timer = %FinTimer
@onready var animacion_enfrentamiento: AnimacionEnfrentamiento = %AnimacionEnfrentamiento

func _enter_tree() -> void:
	EventBus.esconder_personajes.emit.call_deferred()
	EventBus.fin_partido.connect(on_fin_partido)
	

func _ready() -> void:
	animacion_enfrentamiento.animar()
	EventBus.fin_animacion_vs.connect(on_fin_animacion)
	fin_timer.timeout.connect(on_transicion.bind())
	
func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)

func on_fin_partido()-> void:
	print("empieza timer")
	fin_timer.start()

func on_fin_animacion() -> void:
	ControladorPartido.empezar_juego()

func on_transicion() -> void:
	if datos_pantalla.torneo != null and ControladorPartido.enfrentamiento.get_ganador().jugador == ControladorPartido.enfrentamiento.config_jugador_local.jugador:
		datos_pantalla.torneo.avanzar()
		transicion_pantallas(HeadSoccer.Pantalla.TORNEO, datos_pantalla)
	
