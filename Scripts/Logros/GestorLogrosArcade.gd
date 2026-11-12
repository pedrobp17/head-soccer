extends RefCounted
class_name GestorLogrosArcade

var logros_desbloqueados: Dictionary = {}
var logros_a_conseguir: Dictionary = {}
var orden_logros: Array[LogroArcade] = []
var isla_actual: PantallaArcade.Islas
var rival_actual: String
var nivel_actual: int
var jugador_actual: String

func _init(isla: PantallaArcade.Islas, rival: String, nivel: int) -> void:
	jugador_actual = ProgresoPartida.progreso_general.get_jugador_seleccionado()
	isla_actual = isla
	rival_actual = rival
	nivel_actual = nivel
	orden_logros = LogrosArcadeHelper.get_logro_area(isla)
	assert(orden_logros.size() == 3, "Se esperaban dos logros generales y uno de isla.")
	var guardados: Array[bool] = ProgresoPartida.progreso_general.get_logros_arcade(isla, rival, nivel)
	for i in orden_logros.size():
		var logro: LogroArcade = orden_logros[i]
		if logro.objetivo is bool:
			logros_a_conseguir[logro.id] = false
		else:
			logros_a_conseguir[logro.id] = logro.objetivo

		logros_desbloqueados[logro.id] = guardados[i]

func registrar_logro(id: Variant, cantidad: Variant) -> void:
	if not logros_a_conseguir.has(id):
		push_warning("El logro no pertenece al catalogo de este partido.")
		return
	if is_logro_desbloqueado(id):
		return
	if logros_a_conseguir[id] is bool and cantidad is bool:
		logros_a_conseguir[id] = cantidad
	elif logros_a_conseguir[id] is int and cantidad is int:
		logros_a_conseguir[id] -= cantidad
	else:
		push_warning("La cantidad y el objetivo deben ser ambos int o ambos bool.")
		return

func evaluar_logros() -> void:
	var cambios: int = 0
	for id in logros_a_conseguir.keys():
		if is_logro_desbloqueado(id):
			continue
		var cumplido: bool = false
		if logros_a_conseguir[id] is bool:
			cumplido = logros_a_conseguir[id] == true
		elif logros_a_conseguir[id] is int:
			cumplido = logros_a_conseguir[id] <= 0
		if cumplido:
			logros_desbloqueados[id] = true
			cambios += 1
	if cambios > 0:
		ProgresoPartida.progreso_general.set_logros_arcade(
			isla_actual, rival_actual, nivel_actual, get_logros_para_guardar(), jugador_actual)

func is_logro_desbloqueado(id: Variant) -> bool:
	return logros_desbloqueados.get(id, false)

func get_logros_para_guardar() -> Array[bool]:
	var resultado: Array[bool] = []
	for logro in orden_logros:
		resultado.append(is_logro_desbloqueado(logro.id))
	return resultado

func get_texto_misiones() -> Array[String]:
	return LogrosArcadeHelper.get_texto_logro(isla_actual)