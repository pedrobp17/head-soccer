extends Control
class_name InfoNivel

const DURACION_ANIMACION := 0.4
const ESCALA_OCULTA := Vector2.ZERO

@onready var estrellas: VBoxContainer = %estrellas
@onready var misiones : Array[Label] = [%mision1, %mision2, %mision3]
@onready var nivel: Label = $nivel
@onready var nombre: Label = $nombre

var escala_base := Vector2.ONE
var tween: Tween


func _ready() -> void:
	escala_base = scale
	pivot_offset = size / 2.0

func mostrar() -> void:
	_matar_tween()
	scale = ESCALA_OCULTA
	show()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_base, DURACION_ANIMACION)

func ocultar() -> void:
	if not visible and scale == ESCALA_OCULTA:
		return
	_matar_tween()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", ESCALA_OCULTA, DURACION_ANIMACION)
	tween.tween_callback(hide)

func refresh_nivel(indice_nivel: int, rival: String, isla: PantallaArcade.Islas) -> void:
	nivel.text = str(indice_nivel + 1)
	nombre.text = NombresPersonajesHelper.get_nombre_normal_to_separacion_espacio(rival)
	var texto_misiones : Array = PantallaArcade.MISIONES_GLOBALES + [PantallaArcade.MISIONES_ISLA.get(isla, "")]
	for i in misiones.size():
		misiones[i].text = texto_misiones[i]

func _matar_tween() -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = null
