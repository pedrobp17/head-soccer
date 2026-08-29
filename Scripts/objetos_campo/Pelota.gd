extends RigidBody2D

class_name Pelota

const VELOCIDAD = 600
const FUERZA_Y = -0.7
const POSICION_INICIAL = Vector2(0, -604)
var estaFuera = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.golpear_pelota.connect(mover)
	EventBus.reposicionar.connect(set_reposicion)

#Move ball in the normal direction of the colision
func mover(normal: Vector2, isFoot):
	var velocidad = VELOCIDAD
	
	#modify variables if the kick is made with the foot
	if isFoot:
		velocidad *= 60
		normal = Vector2( normal.x, FUERZA_Y).normalized()	#apply thrust along the y-axis if it involves the foot
		
	apply_central_force(normal * velocidad)
	

#transmit that the ball go out of the camara
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	estaFuera = true
	
func set_reposicion():
	estaFuera  = true
	
#stop movement of the ball
func _integrate_forces(state: PhysicsDirectBodyState2D):
	if estaFuera:
		state.transform.origin = POSICION_INICIAL
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		estaFuera = false

	
