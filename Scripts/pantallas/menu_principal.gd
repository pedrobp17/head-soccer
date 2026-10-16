extends Pantallas
class_name MenuPrincipal

enum Estado {MENU, SKIN, LOGROS, AJUSTES}

@onready var tipos_menu : Array[CartasPantallaPrincipal] = [%menu, %skin, %Estadisticas, %Ajustes]
@onready var menu_deslizante: MenuDeslizanteModosJuego = $Contenido/MenuDeslizante/manejador
@onready var selector_personajes: ManejadorMenuPersonajes = %SelectorPersonajes
@onready var logros: Logros = %logros
@onready var ajustes: Control = %AjustesContenido

var en_menu_superior := false
var escena_actual : Estado = Estado.MENU
var estado_actual : EstadoMenuPrincipal = null
var creador_estados := CreadorEstadoMenuPrincipal.new()
var item_seleccionado_personajes := 0
var nombre_personaje_seleccionado := "MarkEvans"
var indice_poder_personaje_seleccionado := 0

func _ready() -> void:
	cambiar_estado(Estado.MENU)
	cambiar_foco_barra_superior(false)
	EventBus.item_selected_personajes.connect(on_item_selected_personajes)
	EventBus.item_selected_modos.connect(on_item_selected_modos)

func cambiar_estado( nuevo_estado : Estado ) -> void:
	if estado_actual != null:
		tipos_menu[escena_actual].set_no_actual()
		remove_child(estado_actual)
		estado_actual.queue_free()

	escena_actual = nuevo_estado
	estado_actual = creador_estados.get_fresh_state(nuevo_estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado)
	estado_actual.name = "MaquinaEstadosMenu: " + str(nuevo_estado)
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

func actualizar_selector() -> void:
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
