extends Control
class_name Reloj

const ALERTA_POCO_PORCENTAJE := 10
const DURACION_TRANSICION_COLOR_TIMER := 0.2

@onready var progreso : TextureProgressBar = %BarraTiempo
@onready var tiempo_restante : Label = %Numero

var textura_poco_porcentaje : Texture2D = load("res://Sprites/UI/timer_progress_limite.png")
var textura_normal : Texture2D = load("res://Sprites/UI/timer_progress.png")
var parpadeo_timer : Tween

var esta_en_peligro = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progreso.texture_progress = textura_normal
	progreso.max_value = ControladorPartido.DURACION_JUEGO_SEGUNDOS
	
func set_valor( _tiempo_restante : float ) -> void:
	if _tiempo_restante <= ALERTA_POCO_PORCENTAJE && !esta_en_peligro:
		cambiar_textura(textura_poco_porcentaje)
		cambiar_texto()
		esta_en_peligro = true
		
	tiempo_restante.text = TiempoHelper.get_texto_tiempo(_tiempo_restante)
	progreso.value = _tiempo_restante 
	
func cambiar_textura( textura : Texture2D) -> void:
	var tween = create_tween()
	var color_actual = progreso.tint_progress
	var color_transparente = Color(color_actual.r, color_actual.g, color_actual.b, 0.0)
	
	tween.tween_property(progreso, "tint_progress", color_transparente, DURACION_TRANSICION_COLOR_TIMER)
	tween.tween_callback(func() : progreso.texture_progress = textura)
	tween.tween_property(progreso, "tint_progress", color_actual, DURACION_TRANSICION_COLOR_TIMER)

func cambiar_texto() -> void:
	parpadeo_timer = create_tween().set_loops()
	var color_blanco = Color.html("FFFFFF")
	var color_rojo = Color.html("F60909")
	
	parpadeo_timer.tween_property(tiempo_restante, "modulate", color_rojo, DURACION_TRANSICION_COLOR_TIMER)
	parpadeo_timer.tween_property(tiempo_restante, "modulate", color_blanco, DURACION_TRANSICION_COLOR_TIMER)
