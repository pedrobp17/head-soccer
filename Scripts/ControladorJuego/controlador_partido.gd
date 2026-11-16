extends Node

const DURACION_JUEGO_SEGUNDOS := 1 * 60

enum Estado {INACTIVO, JUGANDO, GOL, RESETEO, TIEMPO_EXTRA, FIN}

var enfrentamiento: Enfrentamientos = null
var creador_estados := CreadorEstadoJuego.new()
var estado_actual: EstadoJuego = null
var tiempo_restante: float
var dificultad_ia: ConfiguracionIA.Dificultad = ConfiguracionIA.Dificultad.DIFICIL
var logros_arcade: GestorLogrosArcade = null
var estadisticas_partido_jugador_local: EstadisticasPartido = null

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
	estadisticas_partido_jugador_local = EstadisticasPartido.new()
	cambiar_estado(Estado.RESETEO)

func parar_juego() -> void:
	if estado_actual != null and estado_actual is EstadoJuegoInactivo:
		return
	cambiar_estado(Estado.INACTIVO)

func jugando_solitario() -> bool:
	return ProgresoPartida.progreso_general.get_modo_jugado() != ProgresoGlobal.Modos.VERSUS
	
func fin_partido() -> bool:
	return tiempo_restante <= 0
	
func ganador_partido() -> String:
	assert(not enfrentamiento.empate())
	return enfrentamiento.ganador

# false: marca el local; true: marca el visitante.
func incrementar_marcador(es_visitante: bool) -> void:
	var tenia_ventaja: bool = enfrentamiento.gana_local()
	if !es_visitante:
		if enfrentamiento.goles_local == 0 and enfrentamiento.goles_visitante == 0:
			estadisticas_partido_jugador_local.primer_gol_jugador_local = true
		estadisticas_partido_jugador_local.ultimo_gol_local_transcurrido = maxf(
			0.0, DURACION_JUEGO_SEGUNDOS - tiempo_restante)
	enfrentamiento.aumentar_marcador(es_visitante)
	var diferencia_goles: int = enfrentamiento.goles_visitante - enfrentamiento.goles_local
	estadisticas_partido_jugador_local.mayor_diferencia_perdiendo_local = maxi(
		estadisticas_partido_jugador_local.mayor_diferencia_perdiendo_local, diferencia_goles)
	if enfrentamiento.gana_local():
		if not tenia_ventaja:
			estadisticas_partido_jugador_local.inicio_ventaja_local = maxf(0.0, tiempo_restante)
	else:
		estadisticas_partido_jugador_local.inicio_ventaja_local = 0.0
	EventBus.cambio_marcador.emit(es_visitante)
