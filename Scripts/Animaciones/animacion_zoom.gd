extends Camera2D
class_name AnimacionZoom

## Devuelve el Tween para que quien lo llame pueda hacer `await tween.finished`
## y sincronizar el resto de la animación con el zoom.
func zoom_to(punto: Vector2, zoom_final: float = 3.5, duracion: float = 1.0) -> Tween:
	var zoom_ini := zoom.x
	var desplazamiento_ini := (punto - global_position) * zoom_ini # dónde se ve el punto ahora
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(func(t: float):
		var z := zoom_ini * pow(zoom_final / zoom_ini, t) # zoom exponencial
		zoom = Vector2(z, z)
		global_position = punto - desplazamiento_ini * (1.0 - t) / z
	, 0.0, 1.0, duracion)
	return tween


func zoom_instantaneo(punto: Vector2, zoom_final: float = 3.5) -> void:
	zoom = Vector2(zoom_final, zoom_final)
	global_position = punto

func zoom_reset(posicion_original: Vector2, duracion: float = 1.0) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", posicion_original, duracion)
	tween.tween_property(self, "zoom", Vector2.ONE, duracion)
	await tween.finished
	EventBus.fin_animacion_zoom_reset.emit()
