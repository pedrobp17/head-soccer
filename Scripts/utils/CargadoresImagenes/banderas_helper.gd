class_name BanderasHelper

static var banderas : Dictionary[String, Texture2D] = {}

static func get_sprite( equipo : String ) -> Texture2D:
	if not banderas.has(equipo):
		banderas.set(equipo, load("res://Sprites/banderas/bandera-%s.png" % equipo))
	return banderas[equipo]
