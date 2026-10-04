extends Control
class_name CartasSeleccionTorneo

const MARCO_GANADOR := Color.RED
const MARCO_PERDEDOR := Color.DODGER_BLUE
const MARCO_SIN_DECIDIR_RESULTADO := Color.BLACK

@onready var personaje: TextureRect = %Personaje
@onready var marco: Panel = %Marco


func inicializar( jugador : String ) -> void:
	personaje.texture = load("res://Sprites/jugadores/iconos_torneos/%s.png" %jugador )
	set_marco(MARCO_SIN_DECIDIR_RESULTADO)

func set_marco( color : Color) -> void:
	var estilo = marco.get_theme_stylebox("panel") as StyleBoxFlat
	if estilo:
		estilo.border_color = color
