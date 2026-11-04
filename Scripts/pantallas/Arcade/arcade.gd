extends Pantallas
class_name PantallaArcade

enum Islas {RAIMON, MARYTIMES, OCCULT, ROYALACADEMY, WILD, BRAIN, ZEUS, GENESIS, NONE}
enum Estado {ISLA, AREA}

const DURACION_ANIMACION_TRANSPARENCIA = 0.4
const CENTRO_MAPA = Vector2(576, 324)
const mapa_direcciones : Dictionary = {
	KEY_LEFT : 0,
	KEY_RIGHT : 1,
	KEY_UP : 2,
	KEY_DOWN : 3
}
const vecinos : Dictionary = {
	Islas.RAIMON : [Islas.NONE,  Islas.OCCULT, Islas.MARYTIMES, Islas.NONE],
	Islas.MARYTIMES : [Islas.NONE, Islas.BRAIN, Islas.ROYALACADEMY, Islas.RAIMON],
	Islas.OCCULT : [Islas.RAIMON, Islas.ZEUS, Islas.GENESIS, Islas.NONE],
	Islas.ROYALACADEMY : [Islas.NONE, Islas.WILD, Islas.NONE, Islas.MARYTIMES],
	Islas.WILD : [Islas.ROYALACADEMY, Islas.NONE, Islas.NONE, Islas.GENESIS],
	Islas.BRAIN : [Islas.MARYTIMES, Islas.GENESIS, Islas.NONE, Islas.NONE],
	Islas.ZEUS : [Islas.OCCULT, Islas.NONE, Islas.NONE, Islas.NONE],
	Islas.GENESIS : [Islas.BRAIN, Islas.NONE, Islas.WILD, Islas.OCCULT],
}

const jugadores_islas : Dictionary = {
	Islas.RAIMON : ["MarkEvans", "AxelBlaze", "XavierFoster"],
	Islas.MARYTIMES : ["HarleyKane"],
	Islas.OCCULT : ["JohanTassman", "NathanJones"],
	Islas.ROYALACADEMY : ["JudeSharp", "CalebStonewall"],
	Islas.WILD : ["GaryLancaster", "AdrianSpeed", "SteveEagle"],
	Islas.BRAIN : ["ThomasFeldt"],
	Islas.ZEUS : ["ByronLove", "ArtieMishman", "JonasDemetrius"],
	Islas.GENESIS : ["WilburWatkins", "NelsonRockwell", "KatieBrown"],
}

@onready var todos_indicadores: Control = %identificadores
@onready var indicadores : Array[IndicadorIsla] = [%indicadorIsla1, %indicadorIsla2, %indicadorIsla3, %indicadorIsla4, %indicadorIsla5, %indicadorIsla6, %indicadorIsla7, %indicadorIsla8 ]
@onready var niveles: Array[IndicadorArea] = [%indicador_area1, %indicador_area2, %indicador_area3, %indicador_area4, %indicador_area5, %indicador_area6 ]
@onready var puntosZoom : Array[Node2D] = [%raimon, %marytimes, %occult, %royalAcademy, %wild, %brain, %zeus, %genesis]
@onready var camera: AnimacionZoom = %Camera2D

var isla_actual : Islas
var islas_desbloqueadas : Array[Islas] 
var estado_actual : EstadoArcade
var creador_estados := CreadorEstadoArcade.new()

func _ready() -> void:
	refresh_islas_desbloqueadas()
	refresh_niveles()
	set_seleccionado(Islas.RAIMON, Islas.NONE)
	cambiar_estado(Estado.ISLA)
	
func cambiar_estado(estado : Estado) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadoArcade: " + str(estado)
	call_deferred("add_child", estado_actual)
	
func refresh_islas_desbloqueadas() -> void:
	islas_desbloqueadas = ProgresoPartida.progreso_general.get_islas_desbloqueadas_arcade()
	for isla in islas_desbloqueadas:
		indicadores[isla].set_desbloqueado()

func refresh_niveles() -> void:
	for nivel in niveles:
		nivel.hide()
		
func set_seleccionado(isla_seleccionada : Islas, isla_anterior : Islas) -> void:
	if isla_anterior != Islas.NONE:
		indicadores[isla_anterior].set_desbloqueado(true)
	isla_actual = isla_seleccionada
	indicadores[isla_seleccionada].set_actual()
	
func get_vecino( _direccion : Key ) -> Islas:
	if mapa_direcciones.has(_direccion):
		return vecinos[isla_actual][mapa_direcciones[_direccion]]
	return Islas.NONE
		

func zoom_a_isla() -> void:
	await camera.zoom_to(puntosZoom[isla_actual].global_position)
	
func zoom_a_centro() -> void:
	await camera.zoom_reset(CENTRO_MAPA)
	
func es_valido( isla : Islas ) -> bool:
	return isla in islas_desbloqueadas

func cambiar_visibilidad_identificadores( es_visible : bool, duracion : float = DURACION_ANIMACION_TRANSPARENCIA) -> void:
	var transparencia_final = 1.0 if es_visible else 0.0
	var tween = create_tween()
	tween.tween_property(todos_indicadores, "modulate:a", transparencia_final, duracion)

func set_niveles_de_isla() -> void:
	var contenedor_posiciones = indicadores[isla_actual].get_node("posicion_niveles")
	var array_posiciones = contenedor_posiciones.get_children()
	var niveles_disponibles = ProgresoPartida.progreso_general.get_progreso_arcade().get_niveles_totales(isla_actual)
	var niveles_vencidos = ProgresoPartida.progreso_general.get_niveles_vencidos_arcade(isla_actual)
	assert(array_posiciones.size() == niveles_disponibles, "no coincide los niveles definidos en la pantalla arcade con los del json")
	
	for i in range(niveles_disponibles):
		var posicion = array_posiciones[i] as Node2D
		var desbloqueado = i <= niveles_vencidos
		var posicion_centrada = posicion.global_position - Vector2(20.25, 37.5)
		niveles[i].inicializar(posicion_centrada, desbloqueado)
		niveles[i].show()
		
