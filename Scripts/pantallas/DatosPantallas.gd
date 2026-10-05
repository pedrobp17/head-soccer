class_name DatosPantallas

var confing_jugador : ConfiguracionJugadorPartido
var torneo : Torneo = null 

static func build() -> DatosPantallas:
	return DatosPantallas.new()
	
func set_config_jugador( _config_jugador : ConfiguracionJugadorPartido) -> DatosPantallas:
	confing_jugador = _config_jugador
	return self
	
func set_torneo( _torneo : Torneo) -> DatosPantallas:
	torneo = _torneo
	return self
