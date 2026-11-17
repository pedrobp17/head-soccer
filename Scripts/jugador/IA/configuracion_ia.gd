class_name ConfiguracionIA
extends Resource

enum Dificultad {DIFICIL, EXTREMA}

@export var dificultad: Dificultad = Dificultad.DIFICIL
@export_range(0.02, 1.0) var reaccion: float = 0.19
@export_range(0.0, 0.2) var variacion_reaccion: float = 0.06
@export_range(0.0, 0.5) var retraso_percepcion: float = 0.12
@export_range(0.2, 2.0) var horizonte: float = 0.50
@export_range(0.0, 60.0) var error_posicion: float = 30.0
@export_range(0.0, 0.5) var error_velocidad: float = 0.16
@export_range(0.0, 0.15) var error_tiempo_accion: float = 0.06
@export_range(1.0, 40.0) var tolerancia: float = 20.0
@export_range(0.3, 1.0) var pausa_patada: float = 0.48
@export_range(0.1, 2.0) var compromiso_disputa: float = 0.65
@export_range(0.0, 0.5) var ventaja_para_salir: float = 0.18
@export_range(0.1, 5.0) var demora_para_presionar: float = 1.5
@export_range(0.0, 100.0) var velocidad_balon_retenido: float = 35.0
@export_range(20.0, 300.0) var distancia_rival_balon_retenido: float = 140.0
@export_range(0.1, 3.0) var compromiso_presion: float = 1.0

static func crear(nivel: Dificultad) -> ConfiguracionIA:
	var configuracion := ConfiguracionIA.new()
	configuracion.dificultad = nivel
	if nivel == Dificultad.EXTREMA:
		configuracion.reaccion = 0.13
		configuracion.variacion_reaccion = 0.04
		configuracion.retraso_percepcion = 0.08
		configuracion.horizonte = 0.65
		configuracion.error_posicion = 16.0
		configuracion.error_velocidad = 0.09
		configuracion.error_tiempo_accion = 0.035
		configuracion.tolerancia = 12.0
		configuracion.pausa_patada = 0.38
	return configuracion
