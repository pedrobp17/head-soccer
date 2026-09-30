extends Node
class_name BarraEstadisticas

const ADAPTADOR_PORCENTAJE_BARRA = 10
const MAPA_COLORES_DIBUJOS = {
	"velocidad": Color.WHITE,
	"salto": Color("78d94b"),
	"golpe": Color("ffc852"),
	"power": Color("eb7f37"),
	"aguante": Color("cbeef2"),
	"vida" : Color("e33723"),
	"?" : Color.WHITE
}

@export var textura_estadistica : Texture2D

@onready var no_seleccionada: Control = %NoSeleccionada
@onready var barra_progreso: ProgressBar = %BarraProgreso
@onready var seleccionada: Control = %Seleccionada
@onready var nombre_estadistica: Label = %nombreEstadistica
@onready var numero_estadistica: Label = %numeroEstadistica
@onready var dibujo_estadistica: TextureRect = %DibujoEstadistica


func inicializar( num_estadistica : int, nombre : String) -> void:
	set_estadistica_no_seleccionada()
	set_color_estadistica(MAPA_COLORES_DIBUJOS[nombre])
	barra_progreso.value = num_estadistica * ADAPTADOR_PORCENTAJE_BARRA
	numero_estadistica.text = str(num_estadistica)
	nombre_estadistica.text = nombre
	dibujo_estadistica.texture = textura_estadistica
	
func set_estadistica_seleccionada() -> void:
	seleccionada.show()
	no_seleccionada.hide()
	
func set_estadistica_no_seleccionada() -> void:
	seleccionada.hide()
	no_seleccionada.show()

func set_color_estadistica( color : Color) -> void:
	nombre_estadistica.add_theme_color_override("font_color", color)
	var estilo = barra_progreso.get_theme_stylebox("fill").duplicate()
	estilo.bg_color = color
	barra_progreso.add_theme_stylebox_override("fill", estilo)
	
