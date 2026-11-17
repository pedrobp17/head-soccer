class_name PredictorPelotaIA
extends RefCounted

## Estimacion de vuelo a partir de lo observado, sin consultar el escenario.
## Un rebote o golpe invalida esta lectura hasta que el personaje lo perciba.
func predecir(posicion: Vector2, velocidad: Vector2, horizonte: float, gravedad_estimada: float) -> Array[Vector3]:
	var muestras: Array[Vector3] = []
	const PASO: float = 0.05
	for indice in range(ceili(horizonte / PASO) + 1):
		var tiempo := minf(indice * PASO, horizonte)
		var futura := posicion + velocidad * tiempo + Vector2.DOWN * 0.5 * gravedad_estimada * tiempo * tiempo
		muestras.append(Vector3(futura.x, futura.y, tiempo))
	return muestras
