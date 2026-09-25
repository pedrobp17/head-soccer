extends EstadoPelota
class_name EstadoPelotaPoder

 #ver si es mejor si se puede hacer q la pelota con su area vaya detectando si colisiona con el jugador contrario y si es asi poder termina
#implementacion = alguien dice cuando termina el poder

func _ready() -> void:
	EventBus.fin_poder.connect(set_fin_poder)


func _enter_tree() -> void:
	desactivar_fisicas()
	ejecutando_poder = true
	
func desactivar_fisicas() -> void:
	pelota.linear_velocity = Vector2.ZERO
	pelota.angular_velocity = 0.0
	
	pelota.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	pelota.freeze = true
	
	
func _process(_delta: float) -> void:
	if not ejecutando_poder:
		peticion_transmision_estado.emit(Pelota.Estado.NORMAL)


func _exit_tree() -> void:
	activar_fisicas()


func set_fin_poder() -> void:
	ejecutando_poder = false


func activar_fisicas() -> void:
	pelota.freeze = false
	#falta añadir direccion de rebote al salir del poder
