extends Node

const DURACION_JUEGO_SEGUNDOS := 1 * 60

enum Estado {INACTIVO, JUGANDO, GOL, RESETEO, TIEMPO_EXTRA, FIN}

var enfrentamiento: Enfrentamientos = null
var creador_estados := CreadorEstadoJuego.new()
var estado_actual: EstadoJuego = null
var tiempo_restante: float
var setup_jugador: Array[String] = ["MarkEvans", "AxelBlaze"] # "" = jugando contra IA , "nombre" = jugando contra jugador 2
var logros_arcade: GestorLogrosArcade = null

func _ready() -> void:
	tiempo_restante = DURACION_JUEGO_SEGUNDOS
	enfrentamiento = Enfrentamientos.new()
	cambiar_estado(Estado.INACTIVO)
	
func cambiar_estado(estado: Estado, datos: DatosEstadoJuego = DatosEstadoJuego.new()) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self, datos)
	estado_actual.peticion_transmitir_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadoJuego: " + str(estado)
	call_deferred("add_child", estado_actual)

func empezar_juego() -> void:
	tiempo_restante = DURACION_JUEGO_SEGUNDOS
	cambiar_estado(Estado.RESETEO)

func parar_juego() -> void:
	if estado_actual != null and estado_actual is EstadoJuegoInactivo:
		return
	cambiar_estado(Estado.INACTIVO)

func jugando_solitario() -> bool:
	return setup_jugador[1].is_empty()
	
func fin_partido() -> bool:
	return tiempo_restante <= 0
	
func ganador_partido() -> String:
	assert(not enfrentamiento.empate())
	return enfrentamiento.ganador

# false: marca el local; true: marca el visitante.
func incrementar_marcador(es_visitante: bool) -> void:
	enfrentamiento.aumentar_marcador(es_visitante)
	EventBus.cambio_marcador.emit(es_visitante)
