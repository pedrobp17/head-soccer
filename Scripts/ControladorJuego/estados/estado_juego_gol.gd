extends EstadoJuego
class_name EstadoJuegoGol

var tiempo := Time.get_ticks_msec()
func _ready() -> void:
	EventBus.fin_animacion_gol.connect( on_fin_animacion_gol)

func _enter_tree() -> void:
	controlador.incrementar_marcador(datos_juego.jugador_anotador)
	tiempo = Time.get_ticks_msec()

func on_fin_animacion_gol() -> void:
	cambiar_estado(ControladorPartido.Estado.RESETEO,  datos_juego)
