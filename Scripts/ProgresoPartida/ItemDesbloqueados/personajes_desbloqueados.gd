extends Resource
class_name PersonajesDesbloqueados

var personajes_desbloqueados = {
	"AdrianSpeed": false,
	"ArtieMishman": true,
	"AxelBlaze": true,
	"ByronLove": false,
	"CalebStonewall": false,
	"GaryLancaster": false,
	"HarleyKane": false,
	"JohanTassman": false,
	"JonasDemetrius": false,
	"JudeSharp": false,
	"KatieBrown": false,
	"MarkEvans": true,
	"NathanJones": false,
	"NelsonRockwell": false,
	"SteveEagle": false,
	"ThomasFeldt": false,
	"WilburWatkins": false,
	"XavierFoster": false
}

func is_desbloqueado( jugador : String) -> bool:
	if !personajes_desbloqueados.has(jugador):
		return false
	return personajes_desbloqueados[jugador]

func desbloquear(jugador : String) -> void:
	personajes_desbloqueados[jugador] = true

func bloquear(jugador : String) -> void:
	personajes_desbloqueados[jugador] = false
