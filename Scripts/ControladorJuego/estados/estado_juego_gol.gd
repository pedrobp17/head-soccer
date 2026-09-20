extends EstadoJuego
class_name EstadoJuegoGol

var tiempo := Time.get_ticks_msec()
func _ready() -> void:
	EventBus.fin_animacion_gol.connect( on_fin_animacion_gol)

func _enter_tree() -> void:
	var indice_jugador_anotador := 0 if datos_juego.jugador_anotador == controlador.jugadores[0] else 1
	controlador.marcador[indice_jugador_anotador] += 1
	EventBus.cambio_marcador.emit(indice_jugador_anotador)
	tiempo = Time.get_ticks_msec()

func on_fin_animacion_gol() -> void:
	cambiar_estado(ControladorPartido.Estado.RESETEO,  datos_juego)
