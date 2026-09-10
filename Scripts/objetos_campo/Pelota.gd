extends RigidBody2D

class_name Pelota

const VELOCIDAD_MAXIMA: float = 3000.0

const VELOCIDAD = 300
const FUERZA_Y = -0.5
const POSICION_INICIAL = Vector2(-6.0, -536.0)

enum Estado {NORMAL, PODER} #para en el futuro controlar la pelota

var estaFuera = false
var estado_actual : EstadoPelota = null
var creador_estados := CreadorEstadoPelota.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.reposicionar.connect(set_reposicion)
	cambiar_estado(Estado.NORMAL)
	

func cambiar_estado( estado : Estado ) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadosPelota: " + str(estado)
	call_deferred("add_child", estado_actual)
	
#Move ball in the normal direction of the colision
func mover(normal: Vector2, es_pie : bool, fuerza : float):
	var velocidad = VELOCIDAD
	
	#modify variables if the kick is made with the foot
	if es_pie:
		velocidad *= fuerza
		normal = Vector2( normal.x, FUERZA_Y).normalized()	#apply thrust along the y-axis if it involves the foot
		
	apply_central_force(normal * velocidad)
	

#transmit that the ball go out of the camara
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	estaFuera = true
	
func set_reposicion():
	estaFuera = true
	
#stop movement of the ball
func _integrate_forces(state: PhysicsDirectBodyState2D):
	if estaFuera:
		state.transform.origin = POSICION_INICIAL
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		estaFuera = false


	
