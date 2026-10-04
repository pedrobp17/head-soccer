extends Node
class_name BotonSeleccionPersonaje

const COLOR_NORMAL_BORDE = Color.BLACK
const COLOR_ACTIVO_BORDE = Color.WHITE
const COLOR_NORMAL_TEXTO = Color.BLACK
const COLOR_ACTIVO_TEXTO = Color("ffd700")

@onready var seleccion: TextureRect = %Seleccion
@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = %SelectorPersonajes
@onready var seleccion_panel: Panel = %SeleccionPanel
@onready var nombre_seleccion: Label = %NombreSeleccion
@onready var bloqueado_panel: Panel = %BloqueadoPanel
@onready var nombre_bloqueado: Label = %NombreBloqueado
@onready var bloqueado: TextureRect = %Bloqueado


var tiene_foco : bool = false
var jugador_central : DatosSeleccionPersonajes = null

func _ready() -> void:
	cambiar_color_borde(COLOR_NORMAL_BORDE, seleccion_panel)
	cambiar_color_texto(COLOR_NORMAL_TEXTO, nombre_seleccion)
	selector_personajes.item_changed.connect(on_item_changed)

func _input(event):
	if !tiene_foco:
		return 
	
	if event.is_action_pressed("ui_accept"):
		if ProgresoPartida.is_personaje_desbloqueado(jugador_central.name):
			EventBus.item_selected_personajes.emit(selector_personajes.get_current_item())
		else:
			pass
			
func  cambiar_color_borde( color : Color, panel : Panel) -> void:
	var estilo = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.border_color = color

func cambiar_color_texto( color : Color, texto : Label) -> void:
	texto.add_theme_color_override("font_color", color)
	
func cambiar_estado_foco( foco : bool) -> void:
	tiene_foco = foco
	var panel = seleccion_panel if ProgresoPartida.is_personaje_desbloqueado(jugador_central.name) else bloqueado_panel
	var texto = nombre_seleccion if ProgresoPartida.is_personaje_desbloqueado(jugador_central.name) else nombre_bloqueado
	if tiene_foco:
		cambiar_color_borde(COLOR_ACTIVO_BORDE, panel)
		cambiar_color_texto(COLOR_ACTIVO_TEXTO, texto)
	else:
		cambiar_color_borde(COLOR_NORMAL_BORDE, panel)
		cambiar_color_texto(COLOR_NORMAL_TEXTO, texto)
	
func on_item_changed( indice ,datos : Variant) -> void:
	jugador_central = datos
	set_panel()

func set_panel() -> void:
	if ProgresoPartida.is_personaje_desbloqueado(jugador_central.name):
		cambiar_color_borde(COLOR_NORMAL_BORDE, seleccion_panel)
		cambiar_color_texto(COLOR_NORMAL_TEXTO, nombre_seleccion)
		show_seleccionar()
	else:
		cambiar_color_borde(COLOR_NORMAL_BORDE, bloqueado_panel)
		cambiar_color_texto(COLOR_NORMAL_TEXTO, nombre_bloqueado)
		show_desbloquear()
		
func show_desbloquear() -> void:
	seleccion.hide()
	bloqueado.show()

func show_seleccionar() -> void:
	seleccion.show()
	bloqueado.hide()
