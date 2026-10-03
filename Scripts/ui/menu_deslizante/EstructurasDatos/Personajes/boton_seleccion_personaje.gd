extends Node
class_name BotonSeleccionPersonaje

const COLOR_NORMAL_BORDE = Color.BLACK
const COLOR_ACTIVO_BORDE = Color.WHITE
const COLOR_NORMAL_TEXTO = Color.BLACK
const COLOR_ACTIVO_TEXTO = Color("ffd700")

@onready var seleccion: TextureRect = %Seleccion
@onready var panel: Panel = %Panel
@onready var bloqueado: TextureRect = %Bloqueado
@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = %SelectorPersonajes
@onready var texto: Label = %Label

var tiene_foco : bool = false
var jugador_central : String = ""

func _ready() -> void:
	cambiar_color_borde(COLOR_NORMAL_BORDE)
	cambiar_color_texto(COLOR_NORMAL_TEXTO)
	selector_personajes.item_changed.connect(on_item_changed)

func _input(event):
	if !tiene_foco:
		return 
	
	if event.is_action_pressed("ui_accept") and ProgresoPartida.is_personaje_desbloqueado(jugador_central):
		EventBus.item_selected.emit(selector_personajes.get_current_item())
		
func  cambiar_color_borde( color : Color) -> void:
	var estilo = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.border_color = color

func cambiar_color_texto( color : Color) -> void:
	texto.add_theme_color_override("font_color", color)
	
func cambiar_estado_foco( foco : bool) -> void:
	tiene_foco = foco
	if tiene_foco:
		cambiar_color_borde(COLOR_ACTIVO_BORDE)
		cambiar_color_texto(COLOR_ACTIVO_TEXTO)
	else:
		cambiar_color_borde(COLOR_NORMAL_BORDE)
		cambiar_color_texto(COLOR_NORMAL_TEXTO)
	
func on_item_changed( indice ,datos : Variant) -> void:
	jugador_central = datos.name
	print( jugador_central)
