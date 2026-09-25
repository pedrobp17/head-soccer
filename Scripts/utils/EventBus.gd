extends Node

signal golpear_pelota(direcion : Vector2, es_pie : bool, fuerza : float )
signal pie_contacto_pelota_en_poder()
signal gol(jugador: String)
signal reposicionar(jugador : String)
signal reposicionar_pelota(jugador_anotador : String)
signal poder_cargado()
signal gastar_poder(es_visitante : bool)
signal inicio_poder()
signal fin_poder()
signal cambiar_barra_vida( vida : float, es_visitante : bool)
signal cambio_marcador( indice : int)
signal fin_animacion_gol
signal fin_partido( jugador_ganador : String , marcador : Array[int])
signal en_tiempo_extra()
	
