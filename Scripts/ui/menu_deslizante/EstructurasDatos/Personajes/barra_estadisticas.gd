extends Node
class_name BarraEstadisticas

const ADAPTADOR_PORCENTAJE_BARRA = 10

@onready var no_seleccionada: Control = %NoSeleccionada
@onready var barra_progreso: ProgressBar = %BarraProgreso
@onready var seleccionada: Control = %Seleccionada
@onready var nombre_estadistica: Label = %nombreEstadistica
@onready var numero_estadistica: Label = %numeroEstadistica


func inicializar( estadistica : int, nombre : String) -> void:
	set_estadistica_no_seleccionada()
	barra_progreso.value = estadistica * ADAPTADOR_PORCENTAJE_BARRA
	numero_estadistica.text = str(estadistica)
	nombre_estadistica.text = nombre

func set_estadistica_seleccionada() -> void:
	seleccionada.show()
	no_seleccionada.hide()
	numero_estadistica.add_theme_color_override("font_color", Color.BLACK)
	
func set_estadistica_no_seleccionada() -> void:
	seleccionada.hide()
	no_seleccionada.show()
	numero_estadistica.add_theme_color_override("font_color", Color.WHITE)
	
