extends Pantallas
class_name PantallaArcade

enum Islas {RAIMON, MARYTIMES, OCCULT, ROYALACADEMY, WILD, BRAIN, ZEUS, GENESIS, NONE}
enum Estado {ISLA, AREA}

const DURACION_ANIMACION_TRANSPARENCIA = 0.4
const CENTRO_MAPA = Vector2(576, 324)
const mapa_direcciones: Dictionary = {
	KEY_LEFT: 0,
	KEY_RIGHT: 1,
	KEY_UP: 2,
	KEY_DOWN: 3
}
const direcciones_opuestas: Dictionary = {
	KEY_LEFT: KEY_RIGHT,
	KEY_RIGHT: KEY_LEFT,
	KEY_UP: KEY_DOWN,
	KEY_DOWN: KEY_UP
}
const movimiento_areas: Dictionary = {
	Islas.RAIMON: [KEY_LEFT, KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN],
	Islas.MARYTIMES: [KEY_UP],
	Islas.OCCULT: [KEY_LEFT, KEY_LEFT, KEY_UP],
	Islas.ROYALACADEMY: [KEY_RIGHT, KEY_RIGHT, KEY_UP],
	Islas.WILD: [KEY_RIGHT, KEY_UP, KEY_RIGHT, KEY_UP, KEY_RIGHT],
	Islas.BRAIN: [KEY_LEFT],
	Islas.ZEUS: [KEY_RIGHT, KEY_UP, KEY_RIGHT, KEY_UP, KEY_RIGHT],
	Islas.GENESIS: [KEY_LEFT, KEY_LEFT, KEY_LEFT, KEY_UP, KEY_RIGHT],
}
const vecinos_isla: Dictionary = {
	Islas.RAIMON: [Islas.NONE, Islas.OCCULT, Islas.MARYTIMES, Islas.NONE],
	Islas.MARYTIMES: [Islas.NONE, Islas.BRAIN, Islas.ROYALACADEMY, Islas.RAIMON],
	Islas.OCCULT: [Islas.RAIMON, Islas.ZEUS, Islas.GENESIS, Islas.NONE],
	Islas.ROYALACADEMY: [Islas.NONE, Islas.WILD, Islas.NONE, Islas.MARYTIMES],
	Islas.WILD: [Islas.ROYALACADEMY, Islas.NONE, Islas.NONE, Islas.GENESIS],
	Islas.BRAIN: [Islas.MARYTIMES, Islas.GENESIS, Islas.NONE, Islas.NONE],
	Islas.ZEUS: [Islas.OCCULT, Islas.NONE, Islas.NONE, Islas.NONE],
	Islas.GENESIS: [Islas.BRAIN, Islas.NONE, Islas.WILD, Islas.OCCULT],
}
const jugadores_islas: Dictionary = {
	Islas.RAIMON: ["MarkEvans", "AxelBlaze", "XavierFoster"],
	Islas.MARYTIMES: ["HarleyKane"],
	Islas.OCCULT: ["JohanTassman", "NathanJones"],
	Islas.ROYALACADEMY: ["JudeSharp", "CalebStonewall"],
	Islas.WILD: ["GaryLancaster", "AdrianSpeed", "SteveEagle"],
	Islas.BRAIN: ["ThomasFeldt"],
	Islas.ZEUS: ["ByronLove", "ArtieMishman", "JonasDemetrius"],
	Islas.GENESIS: ["WilburWatkins", "NelsonRockwell", "KatieBrown"],
}


@onready var todos_indicadores: Control = %identificadores
@onready var indicadores: Array[IndicadorIsla] = [%indicadorIsla1, %indicadorIsla2, %indicadorIsla3, %indicadorIsla4, %indicadorIsla5, %indicadorIsla6, %indicadorIsla7, %indicadorIsla8]
@onready var niveles: Array[IndicadorArea] = [%indicador_area1, %indicador_area2, %indicador_area3, %indicador_area4, %indicador_area5, %indicador_area6]
@onready var puntosZoom: Array[Node2D] = [%raimon, %marytimes, %occult, %royalAcademy, %wild, %brain, %zeus, %genesis]
@onready var camera: AnimacionZoom = %Camera2D
@onready var info_nivel: InfoNivel = %Panel

var isla_actual: Islas
var nivel_inicial_area := -1
var islas_desbloqueadas: Array[Islas]
var estado_actual: EstadoArcade
var creador_estados := CreadorEstadoArcade.new()

func _ready() -> void:
	if datos_pantalla != null and datos_pantalla.isla_arcade != Islas.NONE:
		isla_actual = datos_pantalla.isla_arcade
		nivel_inicial_area = datos_pantalla.nivel_arcade
	refresh_islas_desbloqueadas()
	if isla_actual not in islas_desbloqueadas:
		isla_actual = Islas.RAIMON
		nivel_inicial_area = -1
	refresh_niveles()
	cambiar_estado(Estado.AREA if nivel_inicial_area >= 0 else Estado.ISLA)
	info_nivel.scale = Vector2.ZERO
	info_nivel.hide()
	
func cambiar_estado(estado: Estado) -> void:
	if estado_actual != null:
		# Un nodo en queue_free sigue recibiendo _input hasta el fin del frame:
		# sin esto, el estado viejo podría procesar un input del mismo frame.
		estado_actual.set_process_input(false)
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadoArcade: " + str(estado)
	call_deferred("add_child", estado_actual)
	
func refresh_islas_desbloqueadas() -> void:
	islas_desbloqueadas = ProgresoPartida.progreso_general.get_islas_desbloqueadas_arcade()
	for indicador in indicadores:
		indicador.set_bloqueado()
	for isla in islas_desbloqueadas:
		indicadores[isla].set_desbloqueado()
		indicadores[isla].set_niveles_ganados(ProgresoPartida.progreso_general.get_niveles_vencidos_arcade(isla), ProgresoPartida.progreso_general.get_progreso_arcade().get_niveles_totales(isla))

func refresh_niveles() -> void:
	for nivel in niveles:
		nivel.hide()
		

## Devuelve el Tween del zoom para poder esperar a que termine.
func zoom_a_isla() -> Tween:
	return camera.zoom_to(puntosZoom[isla_actual].global_position)
	
func zoom_a_centro() -> void:
	await camera.zoom_reset(CENTRO_MAPA)
	
func zoom_a_isla_instantaneo() -> void:
	camera.zoom_instantaneo(puntosZoom[isla_actual].global_position)

func cambiar_visibilidad_identificadores(es_visible: bool, duracion: float = DURACION_ANIMACION_TRANSPARENCIA) -> Tween:
	var transparencia_final = 1.0 if es_visible else 0.0
	var tween = create_tween()
	if !todos_indicadores.is_visible():
		todos_indicadores.show()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(todos_indicadores, "modulate:a", transparencia_final, duracion)
	return tween

func get_jugador_nivel(nivel: int) -> String:
	return jugadores_islas[isla_actual][nivel % jugadores_islas[isla_actual].size()]
