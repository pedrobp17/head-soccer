extends CharacterBody2D
class_name  Jugador

const VELOCIDAD = 300.0
const VELOCIDAD_SALTO = -600.0

enum Estado {JUGANDO, PODER, ATURDIDO}
enum ControlScheme {IA, P1, P2}

@export var esquema_control : ControlScheme

@onready var animacion_jugador = %AnimationPlayer
@onready var pie = $Pie

var estado_actual : EstadoJugador = null
var creador_estados := CreadorEstadoJugador.new()
var vida := 100

func _ready() -> void:
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
