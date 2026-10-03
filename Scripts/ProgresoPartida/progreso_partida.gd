extends Node

var personajes_desbloqueados := PersonajesDesbloqueados.new()

func is_personaje_desbloqueado( jugador : String) -> bool:
	return personajes_desbloqueados.is_desbloqueado(jugador)

func desbloquear_jugador(jugador: String) -> void:
	personajes_desbloqueados.desbloquear(jugador)
	
func bloquear_jugador(jugador: String) -> void:
	personajes_desbloqueados.bloquear(jugador)
	
