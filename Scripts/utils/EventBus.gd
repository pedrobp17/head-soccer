extends Node

signal golpear_pelota(direcion : Vector2, es_pie : bool, fuerza : float )
signal pie_contacto_pelota_en_poder()
signal gol(es_visitante: bool)
signal reposicionar(es_visitante: bool)
signal reposicionar_pelota(es_visitante: bool)
signal poder_cargado(es_visitante: bool)
signal gastar_poder(es_visitante : bool)
signal inicio_poder()
signal fin_poder()
signal cambiar_barra_vida( vida : float, es_visitante : bool)
signal cambio_marcador(es_visitante: bool)
signal fin_animacion_gol
signal fin_animacion_vs
signal fin_animacion_nombre
signal fin_animacion_zoom_reset
signal fin_partido()
signal en_tiempo_extra()
signal item_selected_personajes()
signal item_selected_modos()
signal esconder_personajes
signal mostrar_personajes
