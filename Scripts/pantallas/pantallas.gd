extends Node
class_name Pantallas

signal peticion_transicion_pantalla(nueva_pantalla : HeadSoccer.Pantalla, datos : DatosPantallas)

var juego : HeadSoccer = null
var datos_pantalla : DatosPantallas = null

func setup(_juego : HeadSoccer, _datos : DatosPantallas) -> void:
	juego = _juego
	datos_pantalla = _datos
	
func transicion_pantallas( nueva_pantalla : HeadSoccer.Pantalla, datos : DatosPantallas = DatosPantallas.new()) -> void:
	peticion_transicion_pantalla.emit(nueva_pantalla, datos)
