extends Node
class_name EstadoLogros
 
signal peticion_transmision_estado( nuevo_estado : Logros.Estado, datos : DatosEstadoLogros )
 
var logros : Logros = null
var datos_juego : DatosEstadoLogros = null
var nombre_estado : Logros.Estado
 
 
func setup( logros_entrada : Logros, _datos : DatosEstadoLogros ) -> void:
	logros = logros_entrada
	datos_juego = _datos
 
 
func cambiar_estado( nuevo_estado : Logros.Estado, datos : DatosEstadoLogros = DatosEstadoLogros.new() ) -> void:
	peticion_transmision_estado.emit(nuevo_estado, datos)
 
 
func puede_recibir_input() -> bool:
	return logros.tiene_foco and not logros.animacion
 
