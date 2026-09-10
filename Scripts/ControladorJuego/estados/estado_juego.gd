extends Node
class_name EstadoJuego

signal peticion_transmitir_estado( nuevo_estado : ControladorPartido.Estado, datos : DatosEstadoJuego)

var controlador : ControladorPartido = null
var datos_juego : DatosEstadoJuego = null

func setup( _controlador: ControladorPartido, datos : DatosEstadoJuego) -> void:
	controlador = _controlador
	datos_juego = datos
	
func cambiar_estado(nuevo_estado : ControladorPartido.Estado, datos : DatosEstadoJuego = DatosEstadoJuego.new()) -> void:
	peticion_transmitir_estado.emit(nuevo_estado, datos)
