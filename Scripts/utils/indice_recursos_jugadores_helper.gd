class_name IndiceRecursosJugadoresHelper

const MAPA_PERSONAJES = {
	 "NelsonRockwell" : 0 ,
	 "JonasDemetrius": 1,
	 "CalebStonewall" : 2,
	 "WilburWatkins" : 3,
	 "GaryLancaster": 4,
	 "XavierFoster": 5,
	 "JohanTassman" : 6,
	 "ArtieMishman": 7,
	 "ThomasFeldt": 8,
	 "NathanJones" : 9,
	 "AdrianSpeed" : 10,
	 "SteveEagle" : 11,
	 "KatieBrown": 12,
	 "HarleyKane": 13,
	"JudeSharp" : 14,
	 "ByronLove" : 15,
	 "AxelBlaze": 16,
	 "MarkEvans" : 17,
}

static func get_indice( jugador : String) -> int:
	if not MAPA_PERSONAJES.has(jugador):
		return -1
	return MAPA_PERSONAJES[jugador]
