extends Pantallas
class_name MenuPrincipal
	
const mapa_seleccion_opciones : Dictionary ={
	"neutro" : -1,
	"menu" : 0,
	"personajes" : 1
}

@onready var menu_sel = $MenuSeleccionado_Personajes
@onready var personajes_sel = $Menu_PersonajesSeleccionado
@onready var menu_neutral = $Menu_Personajes
@onready var menu_deslizante: MenuDeslizanteModosJuego = %MenuDeslizante
@onready var selector_personajes: ManejadorMenuPersonajes = %SelectorPersonajes

var en_menu_superior := false
var escena_actual := mapa_seleccion_opciones["menu"] 
var item_seleccionado_personajes := 0
var nombre_personaje_seleccionado := "MarkEvans"
var indice_poder_personaje_seleccionado := 0

func _ready():
	show_escena_menu()
	cambiar_foco_escena(true)
	actualizar_selector(mapa_seleccion_opciones["neutro"])
	EventBus.item_selected_personajes.connect(on_item_selected_personajes)
	EventBus.item_selected_modos.connect(on_item_selected_modos)
func _input(event):

	#TRANSICION: menu -> panel_superior
	if event.is_action_pressed("ui_up") and !en_menu_superior and escena_actual == mapa_seleccion_opciones["menu"]:
		en_menu_superior = true
		cambiar_foco_escena(false)
		actualizar_selector(escena_actual)
		return
		
	#TRANSICION: panel_superior -> menu 
	if event.is_action_pressed("ui_down") and en_menu_superior and escena_actual == mapa_seleccion_opciones["menu"]:
		en_menu_superior = false
		cambiar_foco_escena(true)
		actualizar_selector(mapa_seleccion_opciones["neutro"])
		return
	
	#TRANSICION: boton -> panel_superior
	if event.is_action_pressed("ui_up") and !en_menu_superior and escena_actual == mapa_seleccion_opciones["personajes"] and selector_personajes.puedo_subir_menu_principal():
		en_menu_superior = true
		cambiar_foco_escena(false)
		actualizar_selector(mapa_seleccion_opciones["personajes"])
		return
	
	#TRANSICION: panel_superior ->  boton 
	if event.is_action_pressed("ui_down") and en_menu_superior and escena_actual == mapa_seleccion_opciones["personajes"]:
		en_menu_superior = false
		cambiar_foco_escena(true)
		actualizar_selector(mapa_seleccion_opciones["neutro"])
		return
			
	#NO ES TURNO PANEL SUPERIOR
	if !en_menu_superior:
		return
	
	#TRANSICION: panel_superior_personajes -> panel_superior_menu
	if event.is_action_pressed("ui_left") and escena_actual != mapa_seleccion_opciones["menu"] :
		escena_actual = mapa_seleccion_opciones["menu"]
		actualizar_selector(escena_actual)
		show_escena_menu()
		selector_personajes.set_item_central(item_seleccionado_personajes)
	
	#TRANSICION: panel_superior_menu -> panel_superior_personajes
	elif event.is_action_pressed("ui_right") and escena_actual != mapa_seleccion_opciones["personajes"] :
		escena_actual = mapa_seleccion_opciones["personajes"]
		actualizar_selector(escena_actual)
		show_escena_personajes()
		

func cambiar_foco_escena(tiene_foco: bool) -> void:
	if escena_actual == mapa_seleccion_opciones["menu"]:
		menu_deslizante.cambiar_estado_foco(tiene_foco)
	
	elif escena_actual == mapa_seleccion_opciones["personajes"]:
		selector_personajes.cambiar_estado_foco(tiene_foco)

func _process(_delta: float) -> void:
	$Fps.text = str(Engine.get_frames_per_second()) + " FPS"
		
func actualizar_selector(id : int):
	if id == mapa_seleccion_opciones["menu"]:
		menu_sel.show()
		personajes_sel.hide()
		menu_neutral.hide()
	elif id == mapa_seleccion_opciones["personajes"]:
		menu_sel.hide()
		personajes_sel.show()
		menu_neutral.hide()
	else: 
		menu_neutral.show()
		personajes_sel.hide()
		menu_sel.hide()

func on_item_selected_personajes(datos : Variant) -> void:
	item_seleccionado_personajes = datos.indice
	nombre_personaje_seleccionado = datos.name
	
func on_item_selected_modos( datos : Variant) -> void:
	var datos_personaje = DatosJugadores.get_jugador(nombre_personaje_seleccionado)
	ControladorPartido.enfrentamiento.set_jugador_local(datos_personaje.nombre, "mano_magica")#datos_personaje.poderes[indice_poder_personaje_seleccionado])
	transicion_pantallas(datos.pantalla, DatosPantallas.build().set_config_jugador(ControladorPartido.enfrentamiento.config_jugador_local))
	
func show_escena_menu() -> void:
	selector_personajes.hide()
	menu_deslizante.show()
	
func show_escena_personajes() -> void:
	selector_personajes.show()
	menu_deslizante.hide()
