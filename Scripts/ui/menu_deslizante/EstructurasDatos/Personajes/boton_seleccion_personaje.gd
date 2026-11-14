extends Control
class_name BotonSeleccionPersonaje

const COLOR_NORMAL_BORDE = Color.WHITE
const COLOR_ACTIVO_BORDE = Color("05316f")
const COLOR_NORMAL_TEXTO = Color.WHITE
const COLOR_ACTIVO_TEXTO = Color("05316f")
const COLOR_NORMAL_FONDO = Color("05316f")
const COLOR_ACTIVO_FONDO = Color("ffff49")

@onready var seleccion: TextureRect = %Seleccion
@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = %SelectorPersonajes
@onready var seleccion_panel: Panel = %SeleccionPanel
@onready var nombre_seleccion: Label = %NombreSeleccion
@onready var bloqueado_panel: Panel = %BloqueadoPanel
@onready var nombre_bloqueado: Label = %NombreBloqueado
@onready var bloqueado: TextureRect = %Bloqueado


var tiene_foco: bool = false
var jugador_central: DatosSeleccionPersonajes = null
var tween_entrada: Tween

func _ready() -> void:
	cambiar_color_borde(COLOR_NORMAL_BORDE, seleccion_panel)
	cambiar_color_texto(COLOR_NORMAL_TEXTO, nombre_seleccion)
	selector_personajes.item_changed.connect(on_item_changed)

func _input(event):
	if !tiene_foco:
		return
	
	if event.is_action_pressed("ui_accept"):
		if ProgresoPartida.personajes_desbloqueados.get_desbloqueado(jugador_central.name):
			ProgresoPartida.progreso_general.set_jugador_seleccionado(selector_personajes.get_current_item().name)
			ProgresoPartida.progreso_general.set_indice_jugador_seleccionado(selector_personajes.get_current_item().indice)
			ProgresoPartida.progreso_general.guardar_progreso()
			EventBus.item_selected_personajes.emit()
			
			
func cambiar_color_borde(color: Color, panel: Panel) -> void:
	var estilo = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.border_color = color

func cambiar_color_fondo(color: Color, panel: Panel) -> void:
	var estilo = panel.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.bg_color = color

func cambiar_color_texto(color: Color, texto: Label) -> void:
	texto.add_theme_color_override("font_color", color)
	
func cambiar_estado_foco(foco: bool) -> void:
	tiene_foco = foco
	var panel = seleccion_panel if ProgresoPartida.personajes_desbloqueados.get_desbloqueado(jugador_central.name) else bloqueado_panel
	var texto = nombre_seleccion if ProgresoPartida.personajes_desbloqueados.get_desbloqueado(jugador_central.name) else nombre_bloqueado
	if tiene_foco:
		cambiar_color_borde(COLOR_ACTIVO_BORDE, panel)
		cambiar_color_fondo(COLOR_ACTIVO_FONDO, panel)
		cambiar_color_texto(COLOR_ACTIVO_TEXTO, texto)
	else:
		cambiar_color_borde(COLOR_NORMAL_BORDE, panel)
		cambiar_color_fondo(COLOR_NORMAL_FONDO, panel)
		cambiar_color_texto(COLOR_NORMAL_TEXTO, texto)
	
func on_item_changed(indice, datos: Variant) -> void:
	jugador_central = datos
	set_panel()

func set_panel() -> void:
	if ProgresoPartida.personajes_desbloqueados.get_desbloqueado(jugador_central.name):
		show_seleccionar()
	else:
		show_desbloquear()

	cambiar_estado_foco(tiene_foco)
		
func show_desbloquear() -> void:
	seleccion.hide()
	bloqueado.show()

func show_seleccionar() -> void:
	seleccion.show()
	bloqueado.hide()

func animar() -> Tween:
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()
	tween_entrada = create_tween()
	tween_entrada.tween_property(self, "modulate:a", 1.0, ManejadorMenuPersonajes.ANIMACION_TIEMPO / 2.0)
	return tween_entrada

func preparar_animacion() -> void:
	reposicionar()

func reposicionar() -> void:
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()
	tween_entrada = null
	modulate.a = 0.0
