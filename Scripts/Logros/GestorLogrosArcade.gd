extends RefCounted
class_name GestorLogrosArcade

var orden_logros: Array = []
var logros_desbloqueados: Array[bool] = []
var valores_partido: Dictionary = {}
var isla_actual: PantallaArcade.Islas
var rival_actual: String
var nivel_actual: int
var jugador_actual: String

func _init(isla: PantallaArcade.Islas, rival: String, nivel: int) -> void:
	jugador_actual = ProgresoPartida.progreso_general.get_jugador_seleccionado()
	isla_actual = isla
	rival_actual = rival
	nivel_actual = nivel
	orden_logros = LogrosArcadeHelper.get_logros_jugador(rival, nivel)
	assert(orden_logros.size() == 3, "Se esperaban tres logros por encuentro.")
	logros_desbloqueados = ProgresoPartida.progreso_general.get_logros_arcade(isla, rival, nivel)

func registrar_logro(id: int, cantidad: Variant) -> void:
	valores_partido[id] = cantidad

func evaluar_logros() -> void:
	# Todas las estrellas requieren ganar, incluso las opcionales.
	if valores_partido.get(LogrosArcadeHelper.Ids.GANA_PARTIDO, false) != true:
		return
	var cambios: bool = false
	for i in orden_logros.size():
		if logros_desbloqueados[i]:
			continue
		var logro: Dictionary = orden_logros[i]
		var id: int = logro["id"]
		if not valores_partido.has(id):
			continue
		var objetivo: Variant = logro["objetivo"]
		var valor: Variant = valores_partido[id]
		var cumplido: bool = false
		if objetivo is bool and valor is bool:
			cumplido = valor == objetivo
		elif objetivo is int and valor is int:
			cumplido = valor >= objetivo
		if cumplido:
			logros_desbloqueados[i] = true
			cambios = true
	if cambios:
		ProgresoPartida.progreso_general.set_logros_arcade(
			isla_actual, rival_actual, nivel_actual, logros_desbloqueados, jugador_actual)

func is_logro_desbloqueado(id: int) -> bool:
	for i in orden_logros.size():
		if orden_logros[i]["id"] == id and logros_desbloqueados[i]:
			return true
	return false

func get_logros_para_guardar() -> Array[bool]:
	return logros_desbloqueados.duplicate()

func get_texto_misiones() -> Array[String]:
	return LogrosArcadeHelper.get_texto_logro(rival_actual, nivel_actual)
