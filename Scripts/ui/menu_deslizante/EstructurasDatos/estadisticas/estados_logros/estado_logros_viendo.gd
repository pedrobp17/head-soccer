class_name EstadoLogrosViendo
extends EstadoLogros

const DURACION_ANIMACION := 0.5
const COLOR_AMARILLO := Color("ffff49")
const COLOR_BLANCO := Color.WHITE

var tween_flechas: Tween
var ultima_flecha_editada: Panel
var estilo_flecha_1: StyleBoxFlat
var estilo_flecha_2: StyleBoxFlat


func _enter_tree() -> void:
	nombre_estado = Logros.Estado.VIENDO
	logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
	logros.mostrar_estadisticas_personajes()


func _ready() -> void:
	
	estilo_flecha_1 = logros.flecha_1.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	estilo_flecha_2 = logros.flecha_2.get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	logros.flecha_1.add_theme_stylebox_override("panel", estilo_flecha_1)
	logros.flecha_2.add_theme_stylebox_override("panel", estilo_flecha_2)

	EventBus.fin_animacion_nombre.connect(on_fin_animacion_nombre)
	animacion_loop()


func _input(event: InputEvent) -> void:
	if not puede_recibir_input():
		return

	if event.is_action_pressed("ui_left"):
		parar_animacion()
		estilo_flecha_1.bg_color = COLOR_BLANCO
		ultima_flecha_editada = logros.flecha_1

		datos_juego.indice_personaje = posmod(
			datos_juego.indice_personaje - 1,
			logros.numero_personajes
		)

		logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
		logros.jugador.girar_izquierda()

	if event.is_action_pressed("ui_right"):
		parar_animacion()
		estilo_flecha_2.bg_color = COLOR_BLANCO
		ultima_flecha_editada = logros.flecha_2

		datos_juego.indice_personaje = posmod(
			datos_juego.indice_personaje + 1,
			logros.numero_personajes
		)

		logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
		logros.jugador.girar_derecha()

	if event.is_action_pressed("p1_back"):
		get_viewport().set_input_as_handled()
		cambiar_estado(Logros.Estado.ELIGIENDO)


func on_fin_animacion_nombre() -> void:
	if ultima_flecha_editada == logros.flecha_1:
		estilo_flecha_1.bg_color = COLOR_AMARILLO
	elif ultima_flecha_editada == logros.flecha_2:
		estilo_flecha_2.bg_color = COLOR_AMARILLO

	animacion_loop()


func animacion_loop() -> void:
	if tween_flechas and tween_flechas.is_running():
		return

	tween_flechas = create_tween()
	tween_flechas.set_loops()
	tween_flechas.set_trans(Tween.TRANS_SINE)
	tween_flechas.set_ease(Tween.EASE_IN_OUT)

	tween_flechas.tween_property(
		logros.flecha_1, "scale", Vector2(0.5, 0.5), DURACION_ANIMACION
	)
	tween_flechas.parallel().tween_property(
		logros.flecha_2, "scale", Vector2(0.5, 0.5), DURACION_ANIMACION
	)

	tween_flechas.tween_property(
		logros.flecha_1, "scale", Vector2.ONE, DURACION_ANIMACION
	)
	tween_flechas.parallel().tween_property(
		logros.flecha_2, "scale", Vector2.ONE, DURACION_ANIMACION
	)


func parar_animacion() -> void:
	if tween_flechas and tween_flechas.is_running():
		tween_flechas.kill()

	logros.flecha_1.scale = Vector2.ONE
	logros.flecha_2.scale = Vector2.ONE
