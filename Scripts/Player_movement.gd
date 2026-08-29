extends CharacterBody2D
class_name  movimiento_jugador

const VELOCIDAD = 300.0
const VELOCIDAD_SALTO = -600.0
const DURACION_ATURDIMIENTO = 2000

enum Estado {JUGANDO, PODER, ATURDIDO}

@onready var pie = $Pie

var estado := Estado.JUGANDO
var time_empezar_aturdido := Time.get_ticks_msec()
var vida := 100

func _ready() -> void:
	EventBus.reposicionar.connect(set_reposition)

func get_posicion_inicial():
	pass

func get_salto():
	pass
	
func get_izquierda():
	pass
	
func get_derecha():
	pass
	
func get_patada():
	pass

func set_reposition():
	velocity = Vector2.ZERO
	global_position = get_posicion_inicial()

func _physics_process(delta: float) -> void:
	if estado == Estado.JUGANDO:
		movimiento_player(delta)
		if vida == 0:
			estado == Estado.ATURDIDO
			time_empezar_aturdido = Time.get_ticks_msec()
	elif estado == Estado.ATURDIDO:
		if Time.get_ticks_msec() - time_empezar_aturdido > DURACION_ATURDIMIENTO:
			estado = Estado.JUGANDO
			
			
func movimiento_player(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed( get_salto() ) and is_on_floor():
		velocity.y = VELOCIDAD_SALTO

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direccion := Input.get_axis( get_izquierda(), get_derecha() )
	if direccion:
		velocity.x = direccion * VELOCIDAD
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)
		
	if Input.is_action_just_pressed( get_patada() ):
		pie.golpear()
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Pelota:
			# Aplicamos una fuerza en la dirección del impacto
			EventBus.golpear_pelota.emit(-collision.get_normal(), false)

	
