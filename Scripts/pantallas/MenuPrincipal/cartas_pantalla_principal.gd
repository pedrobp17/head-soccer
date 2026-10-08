extends Control
class_name CartasPantallaPrincipal

@export var nombre : String

@onready var menu: Panel = %Menu
@onready var tipo_menu_principal: Label = %Label

func _ready() -> void:
	tipo_menu_principal.text = nombre
	
func set_actual() -> void:
	var estilo := menu.get_theme_stylebox("panel").duplicate()
	estilo.bg_color = Color.WHITE
	menu.add_theme_stylebox_override("panel", estilo)
	
	tipo_menu_principal.add_theme_color_override("font_color", Color.BLACK)


func set_no_actual() -> void:
	var estilo := menu.get_theme_stylebox("panel").duplicate()
	estilo.bg_color = Color.TRANSPARENT
	menu.add_theme_stylebox_override("panel", estilo)
	
	tipo_menu_principal.add_theme_color_override("font_color", Color.WHITE)
