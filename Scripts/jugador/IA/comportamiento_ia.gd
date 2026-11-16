extends Node
class_name ComportamientoIA

var pelota: Pelota
var jugador: Jugador
var rival: Jugador
var porteria_propia: Porteria
var configuracion: ConfiguracionIA = ConfiguracionIA.crear(ConfiguracionIA.Dificultad.DIFICIL)
var direccion: float = 0.0
var saltar: bool = false
var patear: bool = false
var objetivo_x: float = 0.0
var defendiendo: bool = false

var _predictor := PredictorPelotaIA.new()
var _azar := RandomNumberGenerator.new()
var _hasta_decision: float = 0.0
var _hasta_patada: float = 0.0
var _hasta_salto: float = -1.0
var _pausa_salto: float = 0.0
var _suelo_y: float = 0.0
var _avance: float = 1.0
var _limites := Vector2.ZERO

func setup(nuevo_jugador: Jugador, nueva_pelota: Pelota) -> void:
	jugador = nuevo_jugador
	pelota = nueva_pelota
	_azar.randomize()
	reiniciar()

func configurar_partido(oponente: Jugador, propia: Porteria, contraria: Porteria) -> void:
	rival = oponente
	porteria_propia = propia
	_avance = signf(contraria.global_position.x - propia.global_position.x)
	_limites = Vector2(minf(propia.global_position.x, contraria.global_position.x) + 115.0,
		maxf(propia.global_position.x, contraria.global_position.x) - 115.0)

func set_dificultad(nivel: ConfiguracionIA.Dificultad) -> void:
	configuracion = ConfiguracionIA.crear(nivel)
	reiniciar()

func reiniciar() -> void:
	direccion = 0.0
	saltar = false
	patear = false
	_hasta_decision = 0.0
	_hasta_patada = 0.0
	_hasta_salto = -1.0
	_pausa_salto = 0.0
	if is_instance_valid(jugador):
		objetivo_x = jugador.global_position.x
		_suelo_y = jugador.global_position.y

func actualizar(delta: float) -> void:
	saltar = false
	patear = false
	direccion = 0.0
	if not _puede_actuar():
		_hasta_decision = 0.0
		_hasta_salto = -1.0
		return
	if jugador.is_on_floor():
		_suelo_y = jugador.global_position.y
	_hasta_patada = maxf(0.0, _hasta_patada - delta)
	_pausa_salto = maxf(0.0, _pausa_salto - delta)
	_hasta_decision -= delta
	if _hasta_decision <= 0.0:
		_decidir()
		_hasta_decision = configuracion.reaccion
	var distancia := objetivo_x - jugador.global_position.x
	if absf(distancia) > configuracion.tolerancia:
		var velocidad := jugador.estadisticas.get_estadistica("velocidad")
		direccion = clampf(distancia / maxf(velocidad * delta, 0.001), -1.0, 1.0)
	if _hasta_salto >= 0.0:
		_hasta_salto -= delta
		if _hasta_salto <= 0.0:
			saltar = jugador.is_on_floor() and _pausa_salto <= 0.0
			_hasta_salto = -1.0
			if saltar:
				_pausa_salto = 0.25

func _puede_actuar() -> bool:
	return is_instance_valid(jugador) and is_instance_valid(pelota) \
		and is_instance_valid(porteria_propia) and jugador.is_visible_in_tree() \
		and ControladorPartido.estado_actual != null \
		and ControladorPartido.estado_actual.gol_valido() \
		and pelota.estado_actual is EstadoPelotaNormal

func _decidir() -> void:
	var error := _azar.randf_range(-configuracion.error_posicion, configuracion.error_posicion)
	var excluidos: Array[RID] = [jugador.get_rid()]
	if is_instance_valid(rival):
		excluidos.append(rival.get_rid())
	var trayectoria := _predictor.predecir(pelota, configuracion.horizonte, excluidos)
	var linea_defensa := porteria_propia.global_position.x + _avance * 145.0
	defendiendo = false
	for muestra in trayectoria:
		if (muestra.x - linea_defensa) * _avance < 0.0:
			defendiendo = true
			break
	var radio := _radio_jugador(jugador)
	var separacion := radio + 19.0
	var velocidad := jugador.estadisticas.get_estadistica("velocidad")
	objetivo_x = linea_defensa if defendiendo else pelota.global_position.x - _avance * separacion
	var mejor_coste: float = INF
	var salto_elegido: float = -1.0
	for muestra in trayectoria:
		if muestra.z < 0.04:
			continue
		var destino := muestra.x - _avance * separacion + error
		if destino < _limites.x or destino > _limites.y:
			continue
		var distancia := absf(destino - jugador.global_position.x)
		var alcance := velocidad * muestra.z
		if distancia > alcance + configuracion.tolerancia:
			continue
		var demora_salto := _calcular_salto(muestra)
		if demora_salto == -2.0:
			continue
		var coste := muestra.z + distancia / 4000.0
		if demora_salto >= 0.0:
			coste += 0.07
		if is_instance_valid(rival):
			var llegada_rival := absf(rival.global_position.x - muestra.x) / rival.estadisticas.get_estadistica("velocidad")
			if llegada_rival + 0.1 < muestra.z:
				coste += 0.15
		if coste < mejor_coste:
			mejor_coste = coste
			objetivo_x = destino
			salto_elegido = demora_salto
	objetivo_x = clampf(objetivo_x, _limites.x, _limites.y)
	_hasta_salto = salto_elegido
	_decidir_patada()
	# Recuperar una pelota baja a nuestra espalda caminando la empujaria hacia
	# nuestra propia red. Intenta pasar por encima para despejar desde el otro lado.
	var diferencia_pelota := pelota.global_position - jugador.global_position
	var vuelo := -2.0 * jugador.estadisticas.get_velocidad_salto() / GestorEstadisticas.GRAVEDAD_JUGADOR
	if jugador.is_on_floor() and _pausa_salto <= 0.0 \
		and diferencia_pelota.x * _avance < -radio \
		and absf(diferencia_pelota.x) < velocidad * vuelo * 0.7 \
		and absf(diferencia_pelota.y) < 80.0 \
		and (objetivo_x - jugador.global_position.x) * _avance < 0.0:
		_hasta_salto = 0.0
	if _hasta_salto < 0.0 and jugador.is_on_floor() and is_instance_valid(rival):
		var distancia_rival := rival.global_position.x - jugador.global_position.x
		if absf(distancia_rival) < radio + _radio_jugador(rival) + 12.0 \
			and distancia_rival * (objetivo_x - jugador.global_position.x) > 0.0 \
			and absf(objetivo_x - jugador.global_position.x) > 110.0:
			_hasta_salto = 0.0

## -2: inalcanzable; -1: sin salto; >= 0: segundos hasta saltar.
func _calcular_salto(muestra: Vector3) -> float:
	var centro := jugador.capsula.global_position.y - jugador.global_position.y
	var forma := jugador.capsula.shape as CapsuleShape2D
	var semialtura: float = forma.height * absf(jugador.global_scale.y) * 0.5 if forma != null else 55.0
	var y_futura := jugador.global_position.y
	if not jugador.is_on_floor():
		y_futura = minf(_suelo_y, y_futura + jugador.velocity.y * muestra.z + 0.5 * GestorEstadisticas.GRAVEDAD_JUGADOR * muestra.z * muestra.z)
	if absf(muestra.y - (y_futura + centro)) <= semialtura + 19.0:
		return -1.0
	if not jugador.is_on_floor() or _pausa_salto > 0.0:
		return -2.0
	var impulso := jugador.estadisticas.get_velocidad_salto()
	var vuelo := -2.0 * impulso / GestorEstadisticas.GRAVEDAD_JUGADOR
	var demora := maxf(0.0, muestra.z - vuelo * 0.85)
	while demora <= muestra.z:
		var tiempo := muestra.z - demora
		var altura := -(impulso * tiempo + 0.5 * GestorEstadisticas.GRAVEDAD_JUGADOR * tiempo * tiempo)
		if altura > 0.0 and absf(muestra.y - (_suelo_y + centro - altura)) < semialtura + 16.0:
			return demora
		demora += 0.025
	return -2.0

func _decidir_patada() -> void:
	if _hasta_patada > 0.0 or jugador.pie.golpeando:
		return
	var futura := pelota.global_position + pelota.velocity * 0.10
	var pie := jugador.pie.global_position
	var delante := (futura.x - jugador.global_position.x) * _avance
	var pelota_a_tiro := delante > -8.0 and delante < _radio_jugador(jugador) + 100.0 \
		and absf(futura.y - pie.y) < 85.0
	var rival_a_tiro := false
	if is_instance_valid(rival) and configuracion.dificultad == ConfiguracionIA.Dificultad.EXTREMA:
		var diferencia := rival.global_position - jugador.global_position
		rival_a_tiro = diferencia.x * _avance > 0.0 and absf(diferencia.x) < 100.0 and absf(diferencia.y) < 80.0
	if pelota_a_tiro or rival_a_tiro:
		patear = true
		_hasta_patada = configuracion.pausa_patada

func _radio_jugador(personaje: Jugador) -> float:
	var forma := personaje.capsula.shape as CapsuleShape2D
	return forma.radius * absf(personaje.global_scale.x) if forma != null else 40.0
