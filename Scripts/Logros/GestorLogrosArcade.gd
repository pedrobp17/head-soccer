extends Node

var logros_desbloqueados: Dictionary = {}
var logros_a_conseguir: Dictionary = {}

func registrar_logro(logro: LogroArcade, cantidad: int = 1) -> void:
  if cantidad is int:
    logros_a_conseguir[logro.id] = logros_a_conseguir.get(logro.id, 0) + cantidad
  if cantidad is bool:
    logros_a_conseguir[logro.id] = cantidad
  evaluar_logros(logro)

func evaluar_logros(logro: LogroArcade) -> void:
  if logros_a_conseguir[logro.id] >= logro.objetivo and not logros_desbloqueados.has(logro.id):
    logros_desbloqueados[logro.id] = true
