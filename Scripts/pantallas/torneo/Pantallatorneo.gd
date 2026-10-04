extends Pantallas
class_name PantallaTorneo

const NUM_PARTICIPANTES := 8

@onready var placeholders_posiciones_imagenes : Dictionary = {
	Torneo.Estado.CUARTOS : %Cuartos,
	Torneo.Estado.SEMIS : %Semis,
	Torneo.Estado.FINAL : %Final,
}
@onready var participantes: Control = %Participantes

var torneo : Torneo = null
var cartas_jugadores_activos : Array[CartasSeleccionTorneo] = []

func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)

func _ready() -> void:
	torneo = Torneo.new(datos_pantalla.confing_jugador)
	refresh_brackets()
	
	set_enfrentamientos()
	situar_participantes()

func refresh_brackets() -> void:
	for estado in range(torneo.estado_actual + 1):
		refresh_bracket_estado(estado)
	
func refresh_bracket_estado(estado : Torneo.Estado) -> void:
	var cartas := get_placeholder_cartas_por_estado(estado)
	if estado < Torneo.Estado.COMPLETADO:
		var partidos : Array = torneo.partidos[estado]
		print( str(cartas.size()) + " " + str(partidos.size()*2))
		assert(cartas.size() == 2 * partidos.size())
		for i in range(partidos.size()):
			var partido_actual : Enfrentamientos = partidos[i]
			var carta_local : CartasSeleccionTorneo = cartas[ i * 2 ]
			var carta_visitante : CartasSeleccionTorneo = cartas[ i * 2 + 1 ]
			carta_local.inicializar(partido_actual.config_jugador_local.jugador)
			carta_visitante.inicializar(partido_actual.config_jugador_visitante.jugador)
			 
	
func get_placeholder_cartas_por_estado(estado : Torneo.Estado) -> Array[CartasSeleccionTorneo]:
	var cartas : Array[CartasSeleccionTorneo] = []
	var contenedor: Node = placeholders_posiciones_imagenes[estado]
	for placeholder in contenedor.get_children():
			cartas.append(placeholder)
	return cartas
	
func set_cartas_jugadores_activos() -> void:
	for i in participantes.get_child_count():
		cartas_jugadores_activos.append(participantes.get_child(i))
	
func situar_participantes() -> void:
	for i in NUM_PARTICIPANTES:
		pass
		
func set_enfrentamientos() -> void:
	pass
