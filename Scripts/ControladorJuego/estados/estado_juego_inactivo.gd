extends EstadoJuego
class_name EstadoJuegoInactivo

# Estado "sin partido": no hay _process ni conexiones a EventBus,
# así que entre partidos no se simula nada (reloj, goles, poderes).
# gol_valido() / cargar_poder() / uso_poder() heredan false de EstadoJuego.

func _enter_tree() -> void:
	controlador.tiempo_restante = ControladorPartido.DURACION_JUEGO_SEGUNDOS
