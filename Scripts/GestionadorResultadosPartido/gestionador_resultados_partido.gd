extends RefCounted
class_name GestionadorResultadosPartidos

var estado_actual : EstadoResultadoPartido = null
var creador_estados_resultados := CreadorEstadosResultados.new()

func actualizar_datos_juego(datos_pantalla : DatosPantallas) -> DatosPantallas:
	estado_actual = creador_estados_resultados.get_fresh_state(ProgresoPartida.progreso_general.get_modo_jugado())
	return estado_actual.actualizar_resultado_modo(datos_pantalla)
