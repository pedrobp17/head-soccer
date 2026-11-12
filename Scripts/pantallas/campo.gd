extends Pantallas
class_name Campo

@onready var fin_timer: Timer = %FinTimer
@onready var animacion_enfrentamiento: AnimacionEnfrentamiento = %AnimacionEnfrentamiento

var gestionador_resultados := GestionadorResultadosPartidos.new()

func _enter_tree() -> void:
	EventBus.fin_partido.connect(on_fin_partido)
	ControladorPartido.parar_juego()

func _exit_tree() -> void:
	# Al salir de la pantalla (BACK, fin de partido, cambio de pantalla) nadie
	# debe seguir simulando el partido. El guard cubre el apagado de la app,
	# donde el autoload podrÃ­a estar ya liberado.
	if is_instance_valid(ControladorPartido):
		ControladorPartido.parar_juego()
	

func _ready() -> void:
	EventBus.esconder_personajes.emit.call_deferred()
	animacion_enfrentamiento.animar()
	EventBus.fin_animacion_vs.connect(on_fin_animacion)
	fin_timer.timeout.connect(on_transicion.bind())
	
func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		gestionador_resultados.gestionar_back(self)
		return
	$Fps.text = str(Engine.get_frames_per_second()) + " FPS"
	
func on_fin_partido() -> void:
	gestionador_resultados.actualizar_datos_juego(datos_pantalla)
	fin_timer.start()

func on_fin_animacion() -> void:
	EventBus.mostrar_personajes.emit()
	ControladorPartido.empezar_juego()

func on_transicion() -> void:
	if gestionador_resultados.salida_iniciada:
		return
	gestionador_resultados.salida_iniciada = true
	var nuevos_datos_pantalla = gestionador_resultados.actualizar_datos_juego(datos_pantalla)
	transicion_pantallas(MenuDeslizanteModosJuego.get_pantalla_asociada(ProgresoPartida.progreso_general.get_modo_jugado()), nuevos_datos_pantalla)
