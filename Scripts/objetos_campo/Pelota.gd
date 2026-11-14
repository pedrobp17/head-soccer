extends CharacterBody2D

class_name Pelota

const VELOCIDAD_MAXIMA: float = 3000.0
const VELOCIDAD_INICIAL: float = 300.0
const GRAVEDAD: float = 900.0
const RESTITUCION: float = 0.68
const POSICION_INICIAL := Vector2(-6.0, -536.0)
const IMPULSO_PIE: float = 2200.0
const IMPULSO_CABEZAZO: float = 620.0
const IMPULSO_PORTERIA: float = 90.0
const AMORTIGUACION_AIRE: float = 0.025

enum Estado {NORMAL, PODER, REINICIO}
enum Golpeos {PATADA, CABEZAZO, NONE}

var angulo_aparicion: float = 0.0
var estaFuera: bool = false
var estado_actual: EstadoPelota = null
var creador_estados := CreadorEstadoPelota.new()
var ultimo_golpeo: Golpeos = Golpeos.NONE

@onready var sprite_pelota: Sprite2D = $Pelota

func _ready() -> void:
	cambiar_estado(Estado.NORMAL)
	EventBus.esconder_personajes.connect(on_esconder_personajes)
	EventBus.mostrar_personajes.connect(on_mostrar_personajes)
	EventBus.cambio_marcador.connect(on_cambio_marcador)

func cambiar_estado(estado: Estado) -> void:
	if estado_actual != null:
		estado_actual.queue_free()
	estado_actual = creador_estados.get_fresh_state(estado)
	estado_actual.setup(self)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado.bind())
	estado_actual.name = "MaquinaEstadosPelota: " + str(estado)
	call_deferred("add_child", estado_actual)

func _physics_process(delta: float) -> void:
	if estaFuera:
		reset()
		return
	if estado_actual == null or not estado_actual is EstadoPelotaNormal:
		return
	velocity.y += GRAVEDAD * delta
	velocity.x = move_toward(velocity.x, 0.0, AMORTIGUACION_AIRE * velocity.length() * delta)
	velocity = velocity.limit_length(VELOCIDAD_MAXIMA)
	var restante := velocity * delta
	for _i in range(4):
		var colision := move_and_collide(restante)
		if colision == null:
			break
		resolver_rebote(colision)
		restante = colision.get_remainder().bounce(colision.get_normal()) * RESTITUCION
		if restante.length_squared() <= 0.01:
			break
	velocity = velocity.limit_length(VELOCIDAD_MAXIMA)
	actualizar_rodamiento(delta)

func actualizar_rodamiento(delta: float) -> void:
	var transformacion := global_transform
	var esta_en_suelo := test_move(transformacion, Vector2.DOWN * 2.0)
	if esta_en_suelo:
		sprite_pelota.rotation += velocity.x / 27.0 * delta

func resolver_rebote(colision: KinematicCollision2D) -> void:
	var normal := colision.get_normal()
	var velocidad_entrada := velocity
	if velocidad_entrada.dot(normal) < 0.0:
		velocity = velocidad_entrada.bounce(normal) * RESTITUCION

func mover(normal: Vector2, es_pie: bool, fuerza: float, es_visitante: bool) -> void:
	if estado_actual is EstadoPelotaPoder:
		return
	var direccion := normal.normalized()
	if es_pie:
		direccion = Vector2(direccion.x, -0.5).normalized()
	var impulso_base := IMPULSO_PIE if es_pie else IMPULSO_CABEZAZO
	velocity += direccion * impulso_base * fuerza
	velocity = velocity.limit_length(VELOCIDAD_MAXIMA)
	ReproductorAudio.play(ReproductorAudio.Sonidos.DISPARO)
	if !es_visitante:
		ultimo_golpeo = Golpeos.PATADA if es_pie else Golpeos.CABEZAZO
	else:
		ultimo_golpeo = Golpeos.NONE

func mover_guiado(posicion: Vector2) -> void:
	if estado_actual is EstadoPelotaPoder:
		global_position = posicion

func empujar_desde_porteria(direccion: Vector2) -> void:
	if estado_actual is EstadoPelotaNormal:
		velocity += direccion.normalized() * IMPULSO_PORTERIA
		velocity = velocity.limit_length(VELOCIDAD_MAXIMA)

func reset() -> void:
	estaFuera = false
	global_position = POSICION_INICIAL
	ultimo_golpeo = Golpeos.NONE
	velocity = Vector2.DOWN.rotated(angulo_aparicion) * VELOCIDAD_INICIAL

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	estaFuera = true

func on_esconder_personajes() -> void:
	hide()

func on_mostrar_personajes() -> void:
	show()

func on_cambio_marcador(es_visitante: bool) -> void:
	if es_visitante or ControladorPartido.estadisticas_partido_jugador_local == null:
		return
	var tipo_gol: LogrosArcadeHelper.Ids
	if ultimo_golpeo == Golpeos.CABEZAZO:
		tipo_gol = LogrosArcadeHelper.Ids.GOL_CABEZAZO
	elif ultimo_golpeo == Golpeos.PATADA:
		tipo_gol = LogrosArcadeHelper.Ids.GOL_PATADA
	else:
		return
	ControladorPartido.estadisticas_partido_jugador_local.tipos_goles[tipo_gol] += 1
