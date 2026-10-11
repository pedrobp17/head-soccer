class_name DatosEstadoLogros
extends RefCounted
 
# Datos que se pasan de un estado a otro al cambiar.
 
var indice_personaje : int = 0
 
 
static func build() -> DatosEstadoLogros:
	return DatosEstadoLogros.new()
 
 
func set_indice_personaje( indice : int ) -> DatosEstadoLogros:
	indice_personaje = indice
	return self
 
