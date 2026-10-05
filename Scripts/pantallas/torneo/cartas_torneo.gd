extends Control
class_name CartasSeleccionTorneo

const MARCO_PERDEDOR  := Color.RED
const MARCO_GANADOR := Color.DODGER_BLUE
const MARCO_SIN_DECIDIR_RESULTADO := Color.BLACK
const NIVEL_OPACIDAD := 0.5
const TIEMPO_TRANSICION := 0.3

@onready var personaje: TextureRect = %Personaje
@onready var marco: Panel = %Marco
@onready var marcador: Label = %Marcador
@onready var jugador_seleccionado: Panel = %JugadorSeleccionado

var estilo_panel = null

func inicializar( jugador : String ) -> void:
	personaje.texture = load("res://Sprites/jugadores/iconos_torneos/%s.png" %jugador )
	estilo_panel = marco.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	marco.add_theme_stylebox_override("panel", estilo_panel)
	set_sin_definir()
	marcador.hide()
	jugador_seleccionado.hide()
	
func set_marco( color : Color, animacion : bool = false) -> void:
	
	if estilo_panel:
		if animacion:
			var tween = create_tween().set_parallel(true)
			tween.tween_property(estilo_panel, "bg_color:a", NIVEL_OPACIDAD, TIEMPO_TRANSICION)	
			tween.tween_property(estilo_panel, "border_color", color, TIEMPO_TRANSICION)
		else:
			estilo_panel.bg_color.a = 0.0
			estilo_panel.border_color = color

func set_ganador(goles : int) -> void:
	set_marco(MARCO_GANADOR, true)
	marcador.text = str(goles)
	marcador.show()
	jugador_seleccionado.hide()
		
func set_perdedor(goles : int) -> void:
	set_marco(MARCO_PERDEDOR, true)
	marcador.text = str(goles)
	marcador.show()
	jugador_seleccionado.hide()

func set_sin_definir() -> void:
	set_marco(MARCO_SIN_DECIDIR_RESULTADO)

func set_jugador_seleccionado() -> void:
	jugador_seleccionado.show()
	
