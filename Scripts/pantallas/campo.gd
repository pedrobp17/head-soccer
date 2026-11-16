extends Pantallas
class_name Campo

@onready var fin_timer: Timer = %FinTimer
@onready var animacion_enfrentamiento: AnimacionEnfrentamiento = %AnimacionEnfrentamiento

var gestionador_resultados := GestionadorResultadosPartidos.new()
var selector_ia: PanelContainer

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
	crear_selector_ia()

func crear_selector_ia() -> void:
	if not ControladorPartido.jugando_solitario():
		return
	var capa := CanvasLayer.new()
	capa.layer = 10
	add_child(capa)
	selector_ia = PanelContainer.new()
	selector_ia.position = Vector2(20.0, 40.0)
	capa.add_child(selector_ia)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	selector_ia.add_child(fila)
	var etiqueta := Label.new()
	etiqueta.text = "Dificultad del rival"
	fila.add_child(etiqueta)
	var opciones := OptionButton.new()
	opciones.add_item("Difícil", ConfiguracionIA.Dificultad.DIFICIL)
	opciones.add_item("Extrema", ConfiguracionIA.Dificultad.EXTREMA)
	opciones.select(ControladorPartido.dificultad_ia)
	opciones.focus_mode = Control.FOCUS_NONE
	fila.add_child(opciones)
	opciones.item_selected.connect(func(indice: int) -> void:
		%ContenedorPersonajes.set_dificultad_ia(opciones.get_item_id(indice)))
	
func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		gestionador_resultados.gestionar_back(self)
		return
	$Fps.text = str(Engine.get_frames_per_second()) + " FPS"
	
func on_fin_partido() -> void:
	gestionador_resultados.actualizar_datos_juego(datos_pantalla)
	fin_timer.start()

func on_fin_animacion() -> void:
	if is_instance_valid(selector_ia):
		selector_ia.hide()
	EventBus.mostrar_personajes.emit()
	ControladorPartido.empezar_juego()

func on_transicion() -> void:
	if gestionador_resultados.salida_iniciada:
		return
	gestionador_resultados.salida_iniciada = true
	var nuevos_datos_pantalla = gestionador_resultados.actualizar_datos_juego(datos_pantalla)
	transicion_pantallas(MenuDeslizanteModosJuego.get_pantalla_asociada(ProgresoPartida.progreso_general.get_modo_jugado()), nuevos_datos_pantalla)
