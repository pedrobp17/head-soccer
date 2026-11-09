class_name DatosPantallas

var torneo : Torneo = null 
var isla_arcade : PantallaArcade.Islas = PantallaArcade.Islas.NONE
var nivel_arcade : int = -1

static func build() -> DatosPantallas:
	return DatosPantallas.new()
	
func set_torneo( _torneo : Torneo) -> DatosPantallas:
	torneo = _torneo
	return self

func set_contexto_arcade( isla : PantallaArcade.Islas, nivel : int) -> DatosPantallas:
	isla_arcade = isla
	nivel_arcade = nivel
	return self
