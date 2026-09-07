extends EstadoPelota
class_name EstadoPelotaNormal


func _ready() -> void:
	EventBus.golpear_pelota.connect(pelota.mover)
	EventBus.inicio_poder.connect(set_inicio_poder)

func _enter_tree() -> void:
	ejecutando_poder = false
	
func _physics_process(_delta: float) -> void:
	if pelota.linear_velocity.length() > pelota.VELOCIDAD_MAXIMA:
		pelota.linear_velocity = pelota.linear_velocity.normalized() * pelota.VELOCIDAD_MAXIMA
		
	if ejecutando_poder:
		peticion_transmision_estado.emit(Pelota.Estado.PODER)
		
func set_inicio_poder() -> void:
	ejecutando_poder = true

func _exit_tree() -> void:
	if EventBus.golpear_pelota.is_connected(pelota.mover):
		EventBus.golpear_pelota.disconnect(pelota.mover)
	
	
