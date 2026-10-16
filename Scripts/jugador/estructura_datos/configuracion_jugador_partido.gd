extends Resource
class_name ConfiguracionJugadorPartido

var jugador : String
var poder : String

func setup( _jugador : String, _poder : String) -> ConfiguracionJugadorPartido:
	jugador = _jugador
	poder = _poder
	return self

func serialize() -> Dictionary:
	return {
		"jugador" : jugador,
		"poder" : poder
	}

func deserialize( datos : Dictionary) -> ConfiguracionJugadorPartido:
	
