class_name PredictorPelotaIA
extends RefCounted

## Simula Pelota sin moverla ni emitir señales. Los futuros golpes son desconocidos.
func predecir(pelota: Pelota, horizonte: float, excluidos: Array[RID]) -> Array[Vector3]:
	var muestras: Array[Vector3] = [] # x, y, segundos desde la observacion.
	var transformacion := pelota.global_transform
	var velocidad := pelota.velocity
	var paso: float = 1.0 / Engine.physics_ticks_per_second
	var parametros := PhysicsTestMotionParameters2D.new()
	parametros.exclude_bodies = excluidos
	parametros.margin = pelota.safe_margin
	var resultado := PhysicsTestMotionResult2D.new()
	muestras.append(Vector3(transformacion.origin.x, transformacion.origin.y, 0.0))
	for indice in range(1, ceili(horizonte / paso) + 1):
		velocidad.y += Pelota.GRAVEDAD * paso
		velocidad.x = move_toward(velocidad.x, 0.0, Pelota.AMORTIGUACION_AIRE * velocidad.length() * paso)
		velocidad = velocidad.limit_length(Pelota.VELOCIDAD_MAXIMA)
		var restante := velocidad * paso
		for _rebote in range(4):
			parametros.from = transformacion
			parametros.motion = restante
			if not PhysicsServer2D.body_test_motion(pelota.get_rid(), parametros, resultado):
				transformacion.origin += restante
				break
			transformacion.origin += resultado.get_travel()
			var normal := resultado.get_collision_normal()
			if velocidad.dot(normal) < 0.0:
				velocidad = velocidad.bounce(normal) * Pelota.RESTITUCION
			restante = resultado.get_remainder().bounce(normal) * Pelota.RESTITUCION
			if restante.length_squared() <= 0.01:
				break
		muestras.append(Vector3(transformacion.origin.x, transformacion.origin.y, indice * paso))
	return muestras
