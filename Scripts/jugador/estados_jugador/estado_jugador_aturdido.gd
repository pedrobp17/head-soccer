class_name EstadoJugadorAturdido
extends EstadoJugador

const DURACION_ATURDIMIENTO: float = 0.7
const DESACELERACION_RETROCESO: float = 4000.0
var tiempo_transcurrido: float = 0.0

func _enter_tree() -> void:
	nombre_estado = Jugador.Estado.ATURDIDO
	tiempo_transcurrido = 0.0
	knockback()

func _physics_process(delta: float) -> void:
	if not jugador.is_on_floor():
		jugador.velocity.y += GestorEstadisticas.GRAVEDAD_JUGADOR * delta
	jugador.move_and_slide()
	jugador.velocity.x = move_toward(jugador.velocity.x, 0.0, DESACELERACION_RETROCESO * delta)
	tiempo_transcurrido += delta
	if tiempo_transcurrido >= DURACION_ATURDIMIENTO:
		cambiar_estado(Jugador.Estado.JUGANDO)

func knockback() -> void:
	var distancia: float = jugador.estadisticas.get_estadistica("aguante")
	var rapidez: float = sqrt(2.0 * DESACELERACION_RETROCESO * distancia)
	# Conserva la velocidad vertical si el golpe se recibe en el aire.
	jugador.velocity.x = -rapidez * Jugador.BANDO[jugador.es_visitante]
