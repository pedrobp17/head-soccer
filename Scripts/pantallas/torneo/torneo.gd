extends Pantallas
class_name Torneo

const NUM_PARTICIPANTES := 8

@onready var placeholders_posiciones_imagenes : Control = %PlaceholdersPosiciones
@onready var participantes: Control = %Participantes

var pool_jugadores : Array[RecursosJugador] = []

func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)

func _ready() -> void:
	set_enfrentamientos()
	situar_participantes()

func situar_participantes() -> void:
	for i in NUM_PARTICIPANTES:
		pass
		
func set_enfrentamientos() -> void:
	pass
