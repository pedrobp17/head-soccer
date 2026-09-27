extends Node

# Referencias a los nodos de tu escena
@onready var menu_deslizante = $MenuDeslizante
@onready var menu_sel_personajes = $MenuSeleccionado_Personajes
@onready var menu_personajes_sel = $Menu_PersonajesSeleccionado
@onready var menu_neutral = $Menu_Personajes

# Variables de estado
var en_menu_superior: bool = true
var seleccion_inferior: int = 0 # 0 = "Menu", 1 = "Personajes"

func _ready() -> void:
	# Configuración inicial: empezamos en el carrusel
	activar_menu_superior()

func _input(evento: InputEvent) -> void:
	# Detectar navegación Arriba/Abajo para cambiar entre paneles
	if evento.is_action_pressed("ui_up") and en_menu_superior:
		activar_menu_inferior()
	elif evento.is_action_pressed("ui_down") and not en_menu_superior:
		activar_menu_superior()
		
	# Si estamos en el menú de ABAJO, usamos Izquierda/Derecha aquí
	if not en_menu_superior:
		if evento.is_action_pressed("ui_left"):
			seleccion_inferior = 0
			actualizar_visual_inferior()
		elif evento.is_action_pressed("ui_right"):
			seleccion_inferior = 1
			actualizar_visual_inferior()
		elif evento.is_action_pressed("ui_accept"):
			# Al presionar Enter / Aceptar en el menú de abajo
			if seleccion_inferior == 0:
				print("Ir a la sección de Menú...")
			else:
				print("Ir a la sección de Personajes...")

func activar_menu_superior() -> void:
	en_menu_superior = true
	# Esto encenderá los controles y reactivará el estado "es_actual" visual del carrusel
	menu_deslizante.cambiar_estado_foco(true)
	
	# Mostrar el panel inactivo abajo y ocultar los resaltados
	menu_neutral.show()
	menu_sel_personajes.hide()
	menu_personajes_sel.hide()

func activar_menu_inferior() -> void:
	en_menu_superior = false
	# Esto apagará los controles y quitará el estado "es_actual" visual del carrusel
	menu_deslizante.cambiar_estado_foco(false)
	
	actualizar_visual_inferior()

func actualizar_visual_inferior() -> void:
	# Ocultamos el panel neutral y mostramos la selección correspondiente
	menu_neutral.hide()
	if seleccion_inferior == 0: # "Menu" seleccionado
		menu_sel_personajes.show()
		menu_personajes_sel.hide()
	else: # "Personajes" seleccionado
		menu_sel_personajes.hide()
		menu_personajes_sel.show()
