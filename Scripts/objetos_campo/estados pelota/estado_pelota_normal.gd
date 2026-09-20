extends EstadoPelota
class_name EstadoPelotaNormal


func _ready() -> void:
	EventBus.golpear_pelota.connect(pelota.mover)
	EventBus.inicio_poder.connect(set_inicio_poder)
	EventBus.reposicionar_pelota.connect(set_reposicion)
	
func _enter_tree() -> void:
	ejecutando_poder = false
	
func _physics_process(_delta: float) -> void:
	if pelota.linear_velocity.length() > pelota.VELOCIDAD_MAXIMA:
		pelota.linear_velocity = pelota.linear_velocity.normalized() * pelota.VELOCIDAD_MAXIMA
	
		
func set_inicio_poder() -> void:
	peticion_transmision_estado.emit(Pelota.Estado.PODER)


func set_reposicion(jugador_anotador : String):
	pelota.angulo_aparicion = (randf_range(-20.0, -10.0) if jugador_anotador == ControladorPartido.jugadores[0] else randf_range(10.0, 20.0))
	cambiar_estado(Pelota.Estado.REINICIO)
	
