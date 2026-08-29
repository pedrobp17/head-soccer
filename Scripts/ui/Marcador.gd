extends CanvasLayer
class_name UI

@onready var marcador = %marcador
@onready var logos: Array[TextureRect] = [%equipo1, %equipo2]
@onready var timer: Label = %time
var goles: Array[int] = [0,0]

func _ready():
	EventBus.gol.connect(set_gol)
	actualizar_timer()
	
func set_gol(equipo):
	goles[equipo] += 1
	var texto
	if equipo == 0:
		texto = str(goles[equipo]) + " - " + str(goles[equipo + 1])
	else:
		texto = str(goles[( equipo + 1 ) % 2 ]) + " - " + str(goles[equipo])
	marcador.text = texto
	EventBus.reposicionar.emit()
	
func actualizar_timer() -> void:
	#if controlador_partido.time_left < 0:
	#	timer.modulate = Color.YELLOW
	#timer.text = " "
	pass
