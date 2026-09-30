extends Node
class_name BotonSeleccionPersonaje

const COLOR_NORMAL = Color.BLACK
const COLOR_ACTIVO = Color("#FF8C00")

@onready var seleccion: TextureRect = %Seleccion
@onready var panel: Panel = %Panel
@onready var bloqueado: TextureRect = %Bloqueado

var tiene_foco : bool = false

func _ready() -> void:
	cambiar_color_borde(COLOR_ACTIVO)
	
func  cambiar_color_borde( color : Color) -> void:
	var estilo = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.border_color = color

func cambiar_estado_foco( foco : bool) -> void:
	tiene_foco = foco
