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
var _ancho_campo: float = 1.0
var _disputando: bool = false
var _hasta_reconsiderar: float = 0.0
var _tiempo_balon_retenido: float = 0.0
var _hasta_fin_presion: float = 0.0
var _presionando_por_demora: bool = false
var _historial_pelota: Array[Vector3] = []
var _historial_rival: Array[Vector3] = []
var _tiempo_observacion: float = 0.0
var _observacion_anterior := Vector3.ZERO
var _tiene_observacion: bool = false
var _posicion_observada := Vector2.ZERO
var _velocidad_observada := Vector2.ZERO
var _rival_observado := Vector2.ZERO
var _sesgo_posicion := Vector2.ZERO
var _sesgo_velocidad := Vector2.ONE
var _sesgo_tiempo: float = 0.0
var _gravedad_estimada: float = 850.0
var _hasta_nueva_lectura: float = 0.0

func setup(nuevo_jugador: Jugador, nueva_pelota: Pelota) -> void:
	jugador = nuevo_jugador
	pelota = nueva_pelota
	_azar.randomize()
	reiniciar()

func configurar_partido(oponente: Jugador, propia: Porteria, contraria: Porteria) -> void:
	rival = oponente
	porteria_propia = propia
	_avance = signf(contraria.global_position.x - propia.global_position.x)
	_ancho_campo = maxf(1.0, absf(contraria.global_position.x - propia.global_position.x))
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
	_disputando = false
	_hasta_reconsiderar = 0.0
	_reiniciar_presion()
	_historial_pelota.clear()
	_historial_rival.clear()
	_tiempo_observacion = 0.0
	_tiene_observacion = false
	_hasta_nueva_lectura = 0.0
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
		_disputando = false
		_hasta_reconsiderar = 0.0
		_reiniciar_presion()
		_historial_pelota.clear()
		_historial_rival.clear()
		_tiempo_observacion = 0.0
		_tiene_observacion = false
		return
	# Solo esta captura tiene acceso a la pelota actual. Las decisiones usan memoria.
	if not _observar(delta):
		return
	_actualizar_presion(delta)
	if jugador.is_on_floor():
		_suelo_y = jugador.global_position.y
	_hasta_patada = maxf(0.0, _hasta_patada - delta)
	_pausa_salto = maxf(0.0, _pausa_salto - delta)
	_hasta_reconsiderar = maxf(0.0, _hasta_reconsiderar - delta)
	_hasta_decision -= delta
	if _hasta_decision <= 0.0:
		_decidir()
		_hasta_decision = maxf(0.06, configuracion.reaccion + _azar.randf_range(-configuracion.variacion_reaccion, configuracion.variacion_reaccion))
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

func _observar(delta: float) -> bool:
	_tiempo_observacion += delta
	var actual := pelota.global_position
	var posicion_rival := rival.global_position if is_instance_valid(rival) else jugador.global_position
	_historial_pelota.append(Vector3(actual.x, actual.y, _tiempo_observacion))
	_historial_rival.append(Vector3(posicion_rival.x, posicion_rival.y, _tiempo_observacion))
	var instante_visible := _tiempo_observacion - configuracion.retraso_percepcion
	if _historial_pelota[0].z > instante_visible:
		return false
	while _historial_pelota.size() > 1 and _historial_pelota[1].z <= instante_visible:
		_historial_pelota.pop_front()
		_historial_rival.pop_front()
	var lectura := _historial_pelota[0]
	var posicion := Vector2(lectura.x, lectura.y)
	_hasta_nueva_lectura -= delta
	if _hasta_nueva_lectura <= 0.0:
		# Una mala lectura se mantiene durante parte de la jugada; no tiembla por frame.
		_sesgo_posicion = Vector2(_azar.randf_range(-1.0, 1.0), _azar.randf_range(-0.4, 0.4)) * configuracion.error_posicion
		_sesgo_velocidad = Vector2.ONE + Vector2(_azar.randf_range(-1.0, 1.0), _azar.randf_range(-1.0, 1.0)) * configuracion.error_velocidad
		_sesgo_tiempo = _azar.randf_range(-configuracion.error_tiempo_accion, configuracion.error_tiempo_accion)
		_gravedad_estimada = _azar.randf_range(790.0, 940.0)
		_hasta_nueva_lectura = _azar.randf_range(0.65, 1.05)
	if _tiene_observacion and lectura.z > _observacion_anterior.z:
		var anterior := Vector2(_observacion_anterior.x, _observacion_anterior.y)
		var medida := ((posicion - anterior) / (lectura.z - _observacion_anterior.z)).limit_length(Pelota.VELOCIDAD_MAXIMA)
		_velocidad_observada = _velocidad_observada.lerp(medida * _sesgo_velocidad, 0.65)
	elif not _tiene_observacion:
		_velocidad_observada = Vector2.ZERO
	_observacion_anterior = lectura
	_tiene_observacion = true
	# Mayor precision en corto, sin recuperar la posicion real oculta por el retraso.
	var distancia := posicion.distance_to(jugador.global_position)
	_posicion_observada = posicion + _sesgo_posicion * clampf(distancia / 500.0, 0.35, 1.0)
	var lectura_rival := _historial_rival[0]
	_rival_observado = Vector2(lectura_rival.x, lectura_rival.y)
	return true

func _reiniciar_presion() -> void:
	_tiempo_balon_retenido = 0.0
	_hasta_fin_presion = 0.0
	_presionando_por_demora = false

func _va_perdiendo() -> bool:
	var partido: Enfrentamientos = ControladorPartido.enfrentamiento
	return partido != null and partido.goles_jugador(jugador.es_visitante) \
		< partido.goles_jugador(not jugador.es_visitante)

func _actualizar_presion(delta: float) -> void:
	if not _va_perdiendo() or not is_instance_valid(rival):
		_reiniciar_presion()
		return
	_hasta_fin_presion = maxf(0.0, _hasta_fin_presion - delta)
	# Detectar retencion sostenida usando solo la memoria visual atrasada.
	var reteniendo := _velocidad_observada.length() <= configuracion.velocidad_balon_retenido \
		and _posicion_observada.distance_to(_rival_observado) <= configuracion.distancia_rival_balon_retenido
	if reteniendo:
		_tiempo_balon_retenido += delta
		if _tiempo_balon_retenido >= configuracion.demora_para_presionar:
			_hasta_fin_presion = configuracion.compromiso_presion
	else:
		_tiempo_balon_retenido = 0.0
	# Mantener la salida brevemente tras un toque evita retiradas constantes.
	_presionando_por_demora = _hasta_fin_presion > 0.0

func _puede_actuar() -> bool:
	return is_instance_valid(jugador) and is_instance_valid(pelota) \
		and is_instance_valid(porteria_propia) and jugador.is_visible_in_tree() \
		and ControladorPartido.estado_actual != null \
		and ControladorPartido.estado_actual.gol_valido() \
		and pelota.estado_actual is EstadoPelotaNormal

func _decidir() -> void:
	var trayectoria := _predictor.predecir(_posicion_observada, _velocidad_observada, configuracion.horizonte, _gravedad_estimada)
	var linea_defensa := porteria_propia.global_position.x + _avance * 145.0
	defendiendo = _hay_peligro(trayectoria)
	if not _debe_disputar():
		# Acompaña la jugada desde su mitad, sin perseguir hasta la porteria rival.
		var profundidad := clampf(_profundidad(_posicion_observada.x), 0.0, 1.0)
		objetivo_x = porteria_propia.global_position.x + _avance * _ancho_campo * (0.20 + 0.10 * profundidad)
		objetivo_x = clampf(objetivo_x, _limites.x, _limites.y)
		_hasta_salto = -1.0
		_decidir_patada()
		return
	var radio := _radio_jugador(jugador)
	var separacion := radio + 19.0
	var velocidad := jugador.estadisticas.get_estadistica("velocidad")
	objetivo_x = linea_defensa if defendiendo else _posicion_observada.x - _avance * separacion
	var mejor_coste: float = INF
	var salto_elegido: float = -1.0
	for muestra in trayectoria:
		if muestra.z < 0.04:
			continue
		var destino := muestra.x - _avance * separacion
		if not defendiendo and not _presionando_por_demora and _profundidad(destino) > 0.60:
			continue
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
			var llegada_rival := absf(_rival_observado.x - muestra.x) / rival.estadisticas.get_estadistica("velocidad")
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
	var diferencia_pelota := _posicion_observada - jugador.global_position
	var vuelo := -2.0 * jugador.estadisticas.get_velocidad_salto() / GestorEstadisticas.GRAVEDAD_JUGADOR
	if jugador.is_on_floor() and _pausa_salto <= 0.0 \
		and diferencia_pelota.x * _avance < -radio \
		and absf(diferencia_pelota.x) < velocidad * vuelo * 0.7 \
		and absf(diferencia_pelota.y) < 80.0 \
		and (objetivo_x - jugador.global_position.x) * _avance < 0.0:
		_hasta_salto = 0.0
	if _hasta_salto < 0.0 and jugador.is_on_floor() and is_instance_valid(rival):
		var distancia_rival := _rival_observado.x - jugador.global_position.x
		if absf(distancia_rival) < radio + _radio_jugador(rival) + 12.0 \
			and distancia_rival * (objetivo_x - jugador.global_position.x) > 0.0 \
			and absf(objetivo_x - jugador.global_position.x) > 110.0:
			_hasta_salto = 0.0

func _profundidad(x: float) -> float:
	# 0 = porteria propia; 1 = porteria contraria. Funciona para ambos bandos.
	return (x - porteria_propia.global_position.x) * _avance / _ancho_campo

func _hay_peligro(trayectoria: Array[Vector3]) -> bool:
	var hacia_nuestra_porteria := _velocidad_observada.x * _avance < -60.0
	for muestra in trayectoria:
		# No salir a por balones altos que simplemente pasan sobre nuestra mitad.
		if muestra.y < porteria_propia.global_position.y - 210.0:
			continue
		var profundidad := _profundidad(muestra.x)
		if profundidad < 0.22 or (hacia_nuestra_porteria and profundidad < 0.38):
			return true
	return false

func _debe_disputar() -> bool:
	# El peligro interrumpe inmediatamente la espera y su temporizador.
	if defendiendo:
		_disputando = true
		_hasta_reconsiderar = configuracion.compromiso_disputa
		return true
	# Ir a disputar el balon retenido aunque el rival este lejos o llegue antes.
	if _presionando_por_demora:
		_disputando = true
		return true
	var profundidad := _profundidad(_posicion_observada.x)
	var distancia := absf(_posicion_observada.x - jugador.global_position.x)
	var llegada := distancia / jugador.estadisticas.get_estadistica("velocidad")
	var llegada_rival: float = INF
	if is_instance_valid(rival):
		llegada_rival = absf(_posicion_observada.x - _rival_observado.x) / rival.estadisticas.get_estadistica("velocidad")
	# Limite territorial incluso durante el compromiso: no prolongar una persecucion.
	if profundidad > 0.60:
		_disputando = false
		return false
	if _disputando and _hasta_reconsiderar > 0.0:
		return true
	var salir := distancia < _ancho_campo * 0.28 and llegada + configuracion.ventaja_para_salir < llegada_rival
	# Para continuar basta no haber perdido claramente la ventaja (histeresis).
	if _disputando:
		salir = distancia < _ancho_campo * 0.32 and llegada < llegada_rival + 0.08
	if salir != _disputando:
		_hasta_reconsiderar = configuracion.compromiso_disputa
	_disputando = salir
	return salir

## -2: inalcanzable; -1: sin salto; >= 0: segundos hasta saltar.
func _calcular_salto(muestra: Vector3) -> float:
	muestra.z = maxf(0.01, muestra.z + _sesgo_tiempo)
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
	var futura := _posicion_observada + _velocidad_observada * 0.10
	var pie := jugador.pie.global_position
	var delante := (futura.x - jugador.global_position.x) * _avance
	var pelota_a_tiro := delante > -8.0 and delante < _radio_jugador(jugador) + 100.0 \
		and absf(futura.y - pie.y) < 85.0
	var rival_a_tiro := false
	if is_instance_valid(rival) and configuracion.dificultad == ConfiguracionIA.Dificultad.EXTREMA:
		var diferencia := _rival_observado - jugador.global_position
		rival_a_tiro = diferencia.x * _avance > 0.0 and absf(diferencia.x) < 100.0 and absf(diferencia.y) < 80.0 \
			and _posicion_observada.distance_to(jugador.global_position) < 140.0 \
			and _posicion_observada.distance_to(_rival_observado) < 140.0
	if pelota_a_tiro or rival_a_tiro:
		patear = true
		_hasta_patada = configuracion.pausa_patada

func _radio_jugador(personaje: Jugador) -> float:
	var forma := personaje.capsula.shape as CapsuleShape2D
	return forma.radius * absf(personaje.global_scale.x) if forma != null else 40.0
