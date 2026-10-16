extends Pantallas
class_name MenuPrincipal
	
const mapa_seleccion_opciones : Dictionary ={
	"menu" : 0,
	"personajes" : 1,
	"estadisticas" : 2,
	"ajustes" : 3
}

const mapa_direcciones : Dictionary = {
	"izquierda" : -1,
	"derecha" : 1
}

enum Estado {MENU, SKIN, LOGROS, AJUSTES}

@onready var tipos_menu : Array[CartasPantallaPrincipal] = [%menu, %skin, %Estadisticas, %Ajustes]
@onready var menu_deslizante: MenuDeslizanteModosJuego = %MenuDeslizante
@onready var selector_personajes: ManejadorMenuPersonajes = %SelectorPersonajes
@onready var logros: Logros = %logros

var en_menu_superior := false
var escena_actual : Estado = Estado.MENU
var estado_actual : EstadoMenuPrincipal = null
var creador_estados := CreadorEstadoMenuPrincipal.new() 
var item_seleccionado_personajes := 0
var nombre_personaje_seleccionado := "MarkEvans"
var indice_poder_personaje_seleccionado := 0

func _ready():
	cambiar_estado(Estado.MENU)
	cambiar_foco_barra_superior(false)
	EventBus.item_selected_personajes.connect(on_item_selected_personajes)
	EventBus.item_selected_modos.connect(on_item_selected_modos)

func _input(event):
	'  #TRANSICION: menu -> panel_superior
	if event.is_action_pressed("ui_up") and !en_menu_superior and escena_actual == mapa_seleccion_opciones["menu"]:
		en_menu_superior = true
		cambiar_foco_escena(false)
		actualizar_selector()
		return
		
	#TRANSICION: panel_superior -> menu 
	if event.is_action_pressed("ui_down") and en_menu_superior and escena_actual == mapa_seleccion_opciones["menu"]:
		en_menu_superior = false
		cambiar_foco_escena(true)
		actualizar_selector()
		return
	
	#TRANSICION: boton -> panel_superior
	if event.is_action_pressed("ui_up") and !en_menu_superior and escena_actual == mapa_seleccion_opciones["personajes"] and selector_personajes.puedo_subir_menu_principal():
		en_menu_superior = true
		cambiar_foco_escena(false)
		actualizar_selector()
		return
	
	#TRANSICION: panel_superior ->  boton 
	if event.is_action_pressed("ui_down") and en_menu_superior and escena_actual == mapa_seleccion_opciones["personajes"]:
		en_menu_superior = false
		cambiar_foco_escena(true)
		actualizar_selector()
		return
			
	#NO ES TURNO PANEL SUPERIOR
	if !en_menu_superior:
		return
	
	#TRANSICION: panel_superior_personajes -> panel_superior_menu
	if event.is_action_pressed("ui_left") and escena_actual == mapa_seleccion_opciones["personajes"] :
		escena_actual = mapa_seleccion_opciones["menu"]
		actualizar_selector(mapa_direcciones["derecha"])
		show_escena_menu()
		selector_personajes.set_item_central(item_seleccionado_personajes)
	
	#TRANSICION: panel_superior_menu -> panel_superior_personajes
	elif event.is_action_pressed("ui_right") and escena_actual == mapa_seleccion_opciones["menu"] :
		escena_actual = mapa_seleccion_opciones["personajes"]
		actualizar_selector(mapa_direcciones["izquierda"])
		show_escena_personajes()
	
	elif event.is_action_pressed("ui_right") and escena_actual == mapa_seleccion_opciones["personajes"] :
		escena_actual = mapa_seleccion_opciones["estadisticas"]
		actualizar_selector(mapa_direcciones["izquierda"])
		show_escena_logros()
		
	elif event.is_action_pressed("ui_left") and escena_actual == mapa_seleccion_opciones["estadisticas"] :
		escena_actual = mapa_seleccion_opciones["personajes"]
		actualizar_selector(mapa_direcciones["derecha"])
		show_escena_personajes()'
	pass
func cambiar_estado( nuevo_estado : Estado ) -> void:
	if estado_actual != null:
		tipos_menu[escena_actual].set_no_actual()
		remove_child(estado_actual)
		estado_actual.queue_free()
	
	escena_actual = nuevo_estado
	estado_actual = creador_estados.get_fresh_state(nuevo_estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado)
	estado_actual.name = "MaquinaEstadosJugador: " + str(nuevo_estado)
	call_deferred("add_child", estado_actual)
	actualizar_selector()

func cambiar_foco_barra_superior( a_barra_superior : bool ) -> void:
	en_menu_superior = a_barra_superior
	cambiar_foco_escena(!a_barra_superior)
	actualizar_selector()

func cambiar_foco_escena(tiene_foco: bool) -> void:
	if estado_actual:
		estado_actual.cambiar_foco(tiene_foco)
		
func _process(_delta: float) -> void:
	$Fps.text = str(Engine.get_frames_per_second()) + " FPS"
		
func actualizar_selector(antigua_escena : int = 0) ->void:
	if en_menu_superior:
		tipos_menu[escena_actual].set_actual()
	else:
		tipos_menu[escena_actual].set_no_actual()
 
	

func on_item_selected_personajes(datos : Variant) -> void:
	item_seleccionado_personajes = datos.indice
	nombre_personaje_seleccionado = datos.name
	
func on_item_selected_modos( datos : Variant) -> void:
	var datos_personaje = DatosJugadores.get_jugador(nombre_personaje_seleccionado)
	ControladorPartido.enfrentamiento.set_jugador_local(datos_personaje.nombre, "mano_magica")#datos_personaje.poderes[indice_poder_personaje_seleccionado])
	var torneo = Torneo.new(ControladorPartido.enfrentamiento.config_jugador_local)
	transicion_pantallas(datos.pantalla, DatosPantallas.build().set_config_jugador(ControladorPartido.enfrentamiento.config_jugador_local).set_torneo(torneo))
	
func show_escena_menu() -> void:
	selector_personajes.hide()
	menu_deslizante.show()
	logros.hide()
func show_escena_personajes() -> void:
	selector_personajes.show()
	menu_deslizante.hide()
	logros.hide()

func show_escena_logros() -> void:
	logros.show()
	menu_deslizante.hide()
	selector_personajes.hide()
