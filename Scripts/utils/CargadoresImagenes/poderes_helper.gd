class_name PoderesHelper

static var poderes : Dictionary[String, Array] = {}
static var default_imagen = preload("res://Sprites/poderes/Poder.png")
static func get_icono( jugador : String , _poderes : Array) -> Array:
	if not poderes.has(jugador):
		poderes.set(jugador, [cargar_imagen("res://Sprites/poderes/%s"%_poderes[0]), cargar_imagen("res://Sprites/poderes/%s"%_poderes[0])])
	return poderes[jugador]

static func cargar_imagen(ruta: String) -> Texture2D:
	if ResourceLoader.exists(ruta):
		return load(ruta)
	
	return default_imagen
