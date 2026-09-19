class_name TiempoHelper

static func get_texto_tiempo( tiempo_restante : float ) -> String:
	if tiempo_restante < 0:
		return "FIN"
	else:
		return "%02d" % [tiempo_restante]
