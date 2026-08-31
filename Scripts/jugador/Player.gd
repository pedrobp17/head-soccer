extends CharacterBody2D
class_name  Jugador

const VELOCIDAD = 300.0
const VELOCIDAD_SALTO = -450.0
const BANDO : Dictionary = {
	"visitante" : -1,
	"local" : 1
}

enum Estado {JUGANDO, PODER, ATURDIDO}
enum ControlScheme {IA, P1, P2}

@export var esquema_control : ControlScheme

@onready var controlador_sprite : Sprite2D = %cuerpo
@onready var animacion_jugador : AnimationPlayer = %AnimationPlayer
@onready var pie : Area2D = $Pie

var estadisticas := GestorEstadisticas.new()
var estado_actual : EstadoJugador = null
var creador_estados := CreadorEstadoJugador.new()
var nombre := ""
var equipo := ""
var es_visitante : bool = false

func _ready() -> void:
	set_imagen_personaje()
	cambiar_estado(Estado.JUGANDO)

func _physics_process(delta: float) -> void:
	
	move_and_slide()
	comprobar_colisiones()

func cambiar_estado( estado : Estado ) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self, animacion_jugador)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadosJugador: " + str(estado)
	call_deferred("add_child", estado_actual)
	
func comprobar_colisiones() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		
		if collision.get_collider() is Pelota:
			var direccion := -collision.get_normal()
			var aumentar_fuerza := direccion.y < -0.5
			
			EventBus.golpear_pelota.emit(direccion, aumentar_fuerza)
			
func animacion() -> void:
	if velocity.y == 0:
		animacion_jugador.play("idle")
	else:
		animacion_jugador.stop()
		
func set_imagen_personaje() -> void:
	controlador_sprite.texture = PlayerUtils.obtener_sprite(esquema_control)
	controlador_sprite.set_flip_h(es_visitante)
	var dar_vuelta = BANDO ["visitante"] if es_visitante else BANDO["local"]
	pie.set_sprite(dar_vuelta)

func inicializar(jugador_posicion: Vector2, jugador_data : RecursosJugador , identificador_bando) -> void:
	position = Vector2(jugador_posicion.x * identificador_bando, jugador_posicion.y)
	nombre = jugador_data.nombre
	estadisticas.inicializar(jugador_data.estadisticas)
	equipo = jugador_data.equipo
	es_visitante = bool( BANDO["visitante"] - identificador_bando )
		
	
	
