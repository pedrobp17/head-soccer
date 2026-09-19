extends Node

const DURACION_JUEGO_SEGUNDOS :=  1 * 60

enum Estado {JUGANDO, GOL, RESETEO, INICIALIZANDO, TIEMPO_EXTRA, FIN}

var creador_estados := CreadorEstadoJuego.new()
var estado_actual : EstadoJuego = null
var tiempo_restante : float
var jugadores : Array[String] = ["MarkEvans", "AxelBlaze"]
var setup_jugador : Array[String] = ["MarkEvans","AxelBlaze"] # "" = jugando contra IA , "nombre" = jugando contra jugador 2 
var poderes : Array[String] = ["mano_magica", "mano_magica"]
var marcador : Array[int] = [0,0]


func _ready() -> void:
	tiempo_restante = DURACION_JUEGO_SEGUNDOS
	cambiar_estado(Estado.JUGANDO)
	
func cambiar_estado(estado : Estado, datos : DatosEstadoJuego = DatosEstadoJuego.new()) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self, datos)
	estado_actual.peticion_transmitir_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadoJuego: " + str(estado)
	call_deferred("add_child", estado_actual)

func jugando_solitario() -> bool:
	return setup_jugador[1].is_empty()
