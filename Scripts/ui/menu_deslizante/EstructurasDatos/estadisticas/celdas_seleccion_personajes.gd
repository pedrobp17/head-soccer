extends ScrollContainer
class_name CeldasSeleccionPersonajes

const DISTANCIA_ENTRE_CELDAS := 3 * 64
const DURACION_TRANSICION := 0.15

@onready var barra : VScrollBar = get_v_scroll_bar()
@onready var celdas: GridContainer = %celdas

var numero_elementos : int = 0
var tween_scroll: Tween

func _ready() -> void:
	barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actualizar_celdas()
		
func actualizar_celdas() -> void:
	var array_personajes = ProgresoPartida.personajes_desbloqueados.get_nombres_personajes()
	numero_elementos = array_personajes.size()
	assert(array_personajes.size() == celdas.get_child_count(), "no hay los mismo jugadores que celdas")
	for i in array_personajes.size():
		var imagen : TextureRect = celdas.get_child(i).get_node("imagen")
		imagen.expand_mode = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE
		imagen.texture = ImagenesJugadoresHelper.get_icono(array_personajes[i], false)

func bajar_fila() -> void:
	var nuevo_scroll_vertical = scroll_vertical + DISTANCIA_ENTRE_CELDAS
	scroll_suave(nuevo_scroll_vertical)
	
func subir_fila() -> void:
	var nuevo_scroll_vertical = scroll_vertical - DISTANCIA_ENTRE_CELDAS
	scroll_suave(nuevo_scroll_vertical)
	
func scroll_suave( valor : int) -> void:
	if tween_scroll != null and tween_scroll.is_valid():
		tween_scroll.kill()
	tween_scroll = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_scroll.tween_property(self, "scroll_vertical", valor, DURACION_TRANSICION)

func set_fila_instantanea(fila: int) -> void:
	if tween_scroll != null and tween_scroll.is_valid():
		tween_scroll.kill()
	scroll_vertical = fila * DISTANCIA_ENTRE_CELDAS
