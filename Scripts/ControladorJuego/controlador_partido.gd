extends Node

const DURACION_JUEGO_SEGUNDOS :=  1 * 60

enum Estado {JUGANDO, GOL, RESETEO, INICIALIZANDO, TIEMPO_EXTRA, FIN}

var enfrentamiento : Enfrentamientos = null
var creador_estados := CreadorEstadoJuego.new()
var estado_actual : EstadoJuego = null
var tiempo_restante : float
var setup_jugador : Array[String] = ["MarkEvans","AxelBlaze"] # "" = jugando contra IA , "nombre" = jugando contra jugador 2 



func _ready() -> void:
	tiempo_restante = DURACION_JUEGO_SEGUNDOS
	enfrentamiento = Enfrentamientos.new()
	cambiar_estado(Estado.INICIALIZANDO)
	
func cambiar_estado(estado : Estado, datos : DatosEstadoJuego = DatosEstadoJuego.new()) -> void:
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

func jugando_solitario() -> bool:
	return setup_jugador[1].is_empty()
	
func fin_partido() -> bool:
	return tiempo_restante <= 0
	
func ganador_partido() -> String:
	assert(not enfrentamiento.empate())
	return enfrentamiento.ganador

func incrementar_marcador(jugador_anotador : String) -> void:
	enfrentamiento.aumentar_marcador(jugador_anotador)
	EventBus.cambio_marcador.emit(jugador_anotador)
