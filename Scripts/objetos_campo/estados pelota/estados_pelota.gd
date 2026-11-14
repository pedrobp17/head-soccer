extends Node
class_name EstadoPelota

signal peticion_transmision_estado( nuevo_estado: Pelota.Estado)

var pelota : Pelota = null

func setup( pelota_entrada : Pelota) -> void:
	pelota = pelota_entrada
	
func cambiar_estado(nuevo_estado : Pelota.Estado) -> void:
	peticion_transmision_estado.emit(nuevo_estado)
