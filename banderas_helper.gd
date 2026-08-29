class_name BanderaHelper

static var banderas: Dictionary[String, Texture2D] = {}

static func get_bandera( country : String ) -> Texture2D:
	if not banderas.has(country):
		banderas.set(country, load("res://Sprites/banderas/bandera-%s.png" % [country.to_lower()]))
	return banderas[country]
