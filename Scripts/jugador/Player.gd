extends CharacterBody2D
class_name  Jugador

const CAPA_VISITANTE := 5
const CAPA_LOCAL := 1
const FUERZA_CABEZAZO := 30
const BANDO : Dictionary = {
	true : -1,
	false : 1
}

enum Estado {JUGANDO, PODER, ATURDIDO, REINICIO}
enum ControlScheme {IA, P1, P2}

@export var esquema_control : ControlScheme

@onready var controlador_sprite : Sprite2D = %cuerpo
@onready var animacion_jugador : AnimationPlayer = %AnimationPlayer
@onready var pie : Area2D = $Pie
@onready var capsula : CollisionShape2D = %capsula

var pelota : Pelota = null
var comportamiento_ia := ComportamientoIA.new()
var estadisticas := GestorEstadisticas.new()
var estado_actual : EstadoJugador = null
var creador_estados := CreadorEstadoJugador.new()
var asignador_poder := CreadorPoderes.new()
var poder : Poder = null
var nombre_poder_activo := ""
var nombre := ""
var equipo := ""
var es_visitante : bool = false
var posicion_aparicion := Vector2.ZERO
var fuerza_seguimiento_ia := 0.0
var velocidad_maxima_subida := 0.0
var configuracion_posiciones : Dictionary = {}

func _ready() -> void:
	set_imagen_personaje()
	setup_elementos_personaje()
	setup_poder()
	cambiar_estado(Estado.JUGANDO)
	setup_comportamiento_ia()
	posicion_aparicion = position
	pie.setup( estadisticas.get_estadistica("golpe"), CAPA_LOCAL if es_visitante else CAPA_VISITANTE)
	
	
func cambiar_estado( estado : Estado, datos : DatosEstadoJugador = DatosEstadoJugador.new() ) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self, animacion_jugador, comportamiento_ia, datos)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadosJugador: " + str(estado)
	call_deferred("add_child", estado_actual)
	
func comprobar_colisiones( esperando_ejecutar_poder : bool) -> bool:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var fuerza := 1.0
		
		if collision.get_collider() is Pelota:
			if esperando_ejecutar_poder:
				return true
			
			else:
				var direccion := -collision.get_normal()
				var aumentar_fuerza := direccion.y < -0.5
				fuerza = FUERZA_CABEZAZO
				
				EventBus.golpear_pelota.emit(direccion, aumentar_fuerza, fuerza)
	return false

func animacion( nombre_animacion : String) -> void:
	if animacion_jugador.has_animation(nombre_animacion):
		if nombre_animacion == "idle" and velocity.y != 0:
			animacion_jugador.stop()
		animacion_jugador.play(nombre_animacion)
	else:
		printerr("La animación no existe: ", nombre_animacion)
		
func set_imagen_personaje() -> void:
	controlador_sprite.texture = load("res://Sprites/jugadores/cabezas/" + nombre + ".png")

func inicializar(jugador_posicion: Vector2, jugador_data : RecursosJugador , _pelota : Pelota, identificador_bando : int, poder : String) -> void:	
	position = Vector2(jugador_posicion.x * identificador_bando, jugador_posicion.y)
	nombre = jugador_data.nombre
	nombre_poder_activo = poder
	estadisticas.inicializar(jugador_data.estadisticas)
	equipo = jugador_data.equipo
	es_visitante =  bool(1 - identificador_bando)
	pelota = _pelota
	set_capas_deteccion(es_visitante)
	velocidad_maxima_subida = estadisticas.get_estadistica("salto")
	configuracion_posiciones = {
		"pie" : jugador_data.configuracion_pie,
		"capsula" : jugador_data.configuracion_capsula
	}
	
func setup_comportamiento_ia() -> void:
	comportamiento_ia.setup(self, pelota)
	comportamiento_ia.name = "Comportamiento IA"
	add_child(comportamiento_ia)

func set_capas_deteccion( jugador_es_visitante : bool):
	if jugador_es_visitante:
		set_collision_mask_value(CAPA_LOCAL, true)
		set_collision_layer_value(CAPA_VISITANTE, true)
	else:
		set_collision_mask_value(CAPA_VISITANTE, true)
		set_collision_layer_value(CAPA_LOCAL, true)
		
func puede_tomar_daño() -> bool:
	if estado_actual == null:
		return false
		
	return estado_actual.puede_recibir_daño()

func tomar_daño( daño : float ) -> void:
	if not puede_tomar_daño():
		return 
	
	estadisticas.modificar("vida", -daño)
	EventBus.cambiar_barra_vida.emit( estadisticas.get_estadistica("vida"), es_visitante)

func setup_elementos_personaje():
	capsula.position = Vector2(configuracion_posiciones["capsula"]["x"],configuracion_posiciones["capsula"]["y"])
	pie.position = Vector2(configuracion_posiciones["pie"]["x"],configuracion_posiciones["pie"]["y"])
	
	if capsula.shape:
		capsula.shape = capsula.shape.duplicate()
		if capsula.shape is CapsuleShape2D:
			var nueva_capsula = capsula.shape as CapsuleShape2D
			nueva_capsula.radius = configuracion_posiciones["capsula"]["radio"]
			nueva_capsula.height = configuracion_posiciones["capsula"]["altura"]
	
	scale.x = BANDO[!es_visitante]

func setup_poder() -> void:
	poder = asignador_poder.get_script_poder(nombre_poder_activo)
	var datos_poder = DatosPoderes.get_poder(nombre_poder_activo)
	poder.setup(self, pelota, datos_poder )
