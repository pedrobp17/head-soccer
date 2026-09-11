extends Node
class_name Poder

var jugador : Jugador = null
var pelota : Pelota = null
var nombre : String 
var datos : RecursosPoder = null

func setup(_jugador : Jugador, _pelota : Pelota, _datos : RecursosPoder) -> void:
	jugador = _jugador
	pelota = _pelota
	nombre = _datos.nombre
	datos = _datos
	
func ejecutar() -> void:
	pass
	
func salir() -> void:
	pass
