extends Node

const SPRITE_DEFECTO : Texture = preload("res://Sprites/jugadores/cabezas/MarkEvans.png")

var MAPA_PERSONAJES : Dictionary = {
	Jugador.ControlScheme.P1 : preload("res://Sprites/jugadores/cabezas/AxelBlaze.png"),
	Jugador.ControlScheme.P2 : preload("res://Sprites/jugadores/cabezas/JudeSharp.png"),
	Jugador.ControlScheme.IA : preload("res://Sprites/jugadores/cabezas/ThomasFeldt.png"),
}

func obtener_sprite(esquema_control : Jugador.ControlScheme) -> Texture2D:
	return MAPA_PERSONAJES.get(esquema_control, SPRITE_DEFECTO) #busca si esta el sprite y sino otorga uno por defecto
	
