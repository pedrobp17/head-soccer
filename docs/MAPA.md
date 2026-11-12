# MAPA DEL PROYECTO - Head Soccer (Godot 4.7)

> Generado leyendo todos los scripts (96 `.gd`). Actualízalo con `/mapa`. Lo marcado con (?) no
> se ha podido verificar solo con los scripts (depende de lo que haya en las escenas `.tscn`).

## 1. Visión general
Juego 1 vs 1 de fútbol con cabezas. Hay un menú principal con carrusel de modos y selección de
personaje, un modo torneo (cuartos, semis, final) y la pantalla de partido (`campo`). El flujo
entre pantallas, el partido, el jugador, la pelota y varios menús usan el mismo patrón de máquina
de estados (ver AGENTS.md y la skill `maquinas-de-estado-proyecto`).

## 2. Flujo de pantallas
```
head_soccer.tscn (HeadSoccer, nodo raíz, escena principal)
 └─ cambiar_pantalla(enum) -> FabricaPantallas.get_fresh_screen() -> instancia escena
      ├─ MENU_PRINCIPAL -> MenuPrincipal.tscn   (script MenuPrincipal)
      ├─ TORNEO         -> ModoTorneo.tscn      (script PantallaTorneo)
      ├─ JUGANDO        -> campo.tscn           (script Campo)
      └─ DEFAULT        -> Default.tscn         (script default.gd, vuelve al menú con BACK)
```
- `Pantallas` (base): `signal peticion_transicion_pantalla(nueva_pantalla, datos)`, `setup(juego, datos)`,
  `transicion_pantallas()`. `HeadSoccer` conecta esa signal a su `cambiar_pantalla`.
- `DatosPantallas` (builder): lleva `torneo` (Torneo) y el contexto arcade `isla_arcade`/`nivel_arcade`
  (viaja de ida al partido y de vuelta a la pantalla arcade).
- Transiciones típicas: Menú -> Torneo/Arcade (al elegir modo) -> Jugando (ESPACIO/`ui_select`) -> al terminar,
  la pantalla asociada al modo vía `MenuDeslizanteModosJuego.get_pantalla_asociada()`. Con `p1_back` se sale:
  en arcade vuelve al mapa arcade (conservando la isla); en el resto, al menú.
- Vuelta desde un partido arcade: `campo` devuelve `DatosPantallas` con `isla_arcade`/`nivel_arcade` y
  `PantallaArcade._ready` entra directamente en el estado `AREA`, colocando la cámara al instante sobre la
  isla (`AnimacionZoom.zoom_instantaneo` vía `PantallaArcade.zoom_a_isla_instantaneo`, sin animación de zoom),
  con `PantallaArcade.nivel_inicial_area` (contexto consumido) marcando el nivel actual. Si el jugador sale
  de `AREA` con `p1_back` (decisión propia), `nivel_inicial_area` se limpia a -1 y el próximo acceso a `AREA`
  arranca en el nivel 0.
- Animaciones de transición (`AnimationPlayer` de `head_soccer.tscn`): `CreadorAnimacionesPantallas.
  get_fresh_animacion(origen, destino)` consulta un dict `destino -> { origen -> animación }` — sin entrada
  para el origen, cambio instantáneo. Hoy solo ARCADE tiene animación (`nubes`) y solo si el origen es
  `MENU_PRINCIPAL` (no al volver de `JUGANDO`); el origen lo recuerda `HeadSoccer.pantalla_cargada`.
  `HeadSoccer.transicionando` es true solo mientras dura esa animación (la activa `entrada()` y la
  desactiva `salida()`; si no hay animación, nunca se activa).
- **Candado de input en arcade** (2026-11-10): no se puede cambiar de estado ISLA->AREA ni lanzar
  partido (AREA + `ui_accept`) hasta que la animación de entrada del estado termine de verdad.
  Lo implementa la base `EstadoArcade`:
  - `var escena_lista = false` + `_enter_tree`: `await mostrar_escena(); escena_lista = true`.
  - `_input()` (único punto de entrada) descarta TODO el evento — flechas, `ui_select`/`ui_accept`,
    `p1_back` — mientras `escena_lista == false` o `arcade.juego.transicionando` (nubes) sea true;
    solo entonces delega en `procesar_input(event)`, el gancho que cada estado concreto implementa
    (antes cada estado tenía su propio `_input`). Imprime un `print()` de diagnóstico al descartar
    (temporal, para probar el candado; ver punto 23).
  - Por eso `mostrar_escena()` espera los tweens de verdad: `AnimacionZoom.zoom_to()`,
    `PantallaArcade.zoom_a_isla()`, `PantallaArcade.cambiar_visibilidad_identificadores()` e
    `InfoNivel.mostrar()` devuelven su `Tween` y se hace `await tween.finished` solo si
    `tween.is_running()` (ojo: `await` sobre el objeto Tween NO espera — solo esperan señales y
    corutinas — y `Tween.is_finished()` no existe; si el tween ya terminó, el await colgaría).
  - `PantallaArcade.cambiar_estado()` apaga `set_process_input(false)` al estado viejo antes del
    `queue_free` (un nodo en `queue_free` sigue recibiendo `_input` hasta el fin del frame).
  - `await mostrar_escena()` en la base lleva `@warning_ignore("redundant_await")`: el análisis
    estático lo resuelve contra la base (`pass`, no corrutina), pero en runtime se despacha a la
    subclase, que sí es corrutina. NO quitar el await. El mismo patrón sin candado existe en
    `EstadoMenuPrincipal._enter_tree` (decisión: no tocar el menú; ver punto 24).

## 3. Autoloads (singletons)
| Autoload | Script | Papel |
|---|---|---|
| EventBus | utils/EventBus.gd | Solo declara señales globales (ver sección 11) |
| PlayerUtils | utils/player_utils.gd | Mapa esquema de control -> sprite por defecto |
| DatosJugadores | jugador/base_datos/datos_jugadores.gd | Carga `jugadores.json` -> `RecursosJugador` |
| DatosPoderes | jugador/base_datos/datos_poderes.gd | Carga `poderes.json` -> `RecursosPoder` |
| ControladorPartido | ControladorJuego/controlador_partido.gd | Máquina de estados del partido, reloj, marcador (`enfrentamiento`) |
| ReproductorAudio | Audio/reproductor_audio.gd | Pool de 4 `AudioStreamPlayer`; `play(Sonidos.X)` |
| ProgresoPartida | ProgresoPartida/progreso_partida.gd | Crea un `InfoPersonajes` (progreso/logros de personajes) |

## 4. Máquinas de estados del proyecto
| Dueño | Enum | Creador | Base | Estados concretos |
|---|---|---|---|---|
| HeadSoccer (pantallas) | `HeadSoccer.Pantalla` | FabricaPantallas | Pantallas | MenuPrincipal, PantallaTorneo, Campo, default |
| PantallaArcade (mapa arcade) | `PantallaArcade.Estado` | CreadorEstadoArcade | EstadoArcade | Isla, Area |
| ControladorPartido | `ControladorPartido.Estado` | CreadorEstadoJuego | EstadoJuego | Inactivo, Jugando, Gol, Reseteo, TiempoExtra, Fin |
| Jugador | `Jugador.Estado` | CreadorEstadoJugador | EstadoJugador | Moviendo (JUGANDO), EsperandoPoder, Poder, Aturdido, Reinicio, Gol (vacío) |
| Pelota | `Pelota.Estado` | CreadorEstadoPelota | EstadoPelota | Normal, Poder, Reinicio |
| MenuPrincipal | `MenuPrincipal.Estado` | CreadorEstadoMenuPrincipal | EstadoMenuPrincipal | Menu, Skin, Logros, Ajustes (cada uno envuelve su widget: carrusel, selector, logros, panel) |
| Logros | `Logros.Estado` | CreadorEstadoLogros | EstadoLogros | Eligiendo, Viendo |

## 5. Partido (ControladorPartido + Enfrentamientos)
- `ControladorPartido._ready`: pone `tiempo_restante = DURACION_JUEGO_SEGUNDOS` (ahora 10 s, `1 * 10`, valor de pruebas),
  crea `Enfrentamientos` y entra en INACTIVO (antes entraba en RESETEO: la app arrancaba "jugando" en el menú).
- `empezar_juego()` (llamado por `campo.on_fin_animacion`, tras pulsar ESPACIO en la intro) -> RESETEO;
  `parar_juego()` -> INACTIVO con guard `is EstadoJuegoInactivo` (idempotente). La pantalla `campo` es la dueña
  del ciclo de vida: llama a `parar_juego()` en `_enter_tree`, en `_exit_tree` (con guard `is_instance_valid`
  por el apagado de la app) y al inicio de la rama de BACK.
- `setup_jugador`: array con los dos jugadores; `jugando_solitario()` es true si el visitante está vacío ("" = IA).
- Estados de juego:
  - **INACTIVO**: "sin partido": sin `_process`, sin conectar `EventBus.gol`; pone `tiempo_restante` a tope en
    `_enter_tree` (el HUD de la intro muestra el tiempo correcto). `gol_valido()`/`cargar_poder()`/`uso_poder()`
    heredan false. Es el único estado válido entre partidos (evita que la máquina caducada emita
    `en_tiempo_extra`/`fin_partido` con la nueva pantalla ya cargada).
  - **RESETEO**: emite `reposicionar(anotador)` y pasa a JUGANDO (auto-transición en `_enter_tree`: no se puede "estacionar" en RESETEO).
  - **JUGANDO**: resta tiempo en `_process`; escucha `gol`; al acabar el tiempo va a TIEMPO_EXTRA (empate) o FIN.
    Responde true a `gol_valido()`, `cargar_poder()`, `uso_poder()`.
  - **GOL**: suma marcador (`incrementar_marcador` -> `EventBus.cambio_marcador`), espera `fin_animacion_gol` y va a RESETEO.
  - **TIEMPO_EXTRA**: emite `en_tiempo_extra`; el primer gol suma y va a FIN. `uso_poder()` = false.
  - **FIN**: emite `fin_partido`.
- `Enfrentamientos` (RefCounted-like, sin extends): guarda `config_jugador_local/visitante`, goles, `ganador`,
  `marcador_final`. El visitante por defecto es AxelBlaze/"mano_magica".
- `ConfiguracionJugadorPartido`: pareja (jugador, poder) de un participante.
- **Montaje del partido**: el JUGADOR LOCAL lo fija `menu_principal.on_item_selected_modos` al elegir modo
  (desde el progreso) y, en arcade, también `estado_arcade_area` en `ui_accept` antes de ir a `JUGANDO`
  (local + visitante): quien lanza el partido monta el partido completo, porque el camino BACK -> mapa
  arcade no pasa por el menú (ver punto 22).
- **Resultados al terminar** (`campo.on_transicion`): `GestionadorResultadosPartidos` es una **estrategia
  `RefCounted`**, NO una máquina de estados (se eliminó el andamiaje de máquina el 2026-11-08: señal,
  `connect`, `add_child` diferido, `queue_free` y nombre — era código muerto con tipos errórones y el origen
  de una fuga de memoria por partido). Crea un `EstadoResultadoPartido` por modo con `CreadorEstadosResultados`
  (assert + fallback a la base passthrough para los 6 modos sin estado) y devuelve `datos_pantalla`:
  - **Torneo**: `set_partido_personaje_actual()` + `set_perdido()` si no gana el local (condición `!=`);
    devuelve el MISMO `datos_pantalla` (devolver uno nuevo dejaba `torneo = null` en `Pantallatorneo`).
  - **Arcade**: si gana el local, `completar_nivel_arcade(isla, rival, nivel)` con el contexto de
    `DatosPantallas` (condición `==`: completo si GANO); sin contexto (isla `NONE`) no hace nada.
  - Destino: `MenuDeslizanteModosJuego.get_pantalla_asociada(modo)`.

## 6. Jugador (`Jugador`, Player.gd)
- `CharacterBody2D`. `esquema_control`: IA, P1, P2. `inicializar()` lo llena `apariciones.gd` antes de añadirlo
  (nombre, estadísticas, equipo, bando, pelota, capas de colisión, configuración de pie y cápsula).
- Estadísticas: `GestorEstadisticas` -> valor = (valor_json - 5) * salto_siguiente_nivel + constante.
  Hay `estadisticas_modificadas` (p. ej. vida tras daño) y `reset_estadistica`.
- Entrada: `KeyUtils` mapea acciones por esquema (p1_*, p2_*; BACK solo para P1).
- Estados: Moviendo (movimiento, patada con `pie.golpear()`, espera barra de poder), EsperandoPoder
  (pie con detector de poder activo), Aturdido (knockback 2 s si vida <= 0), Reinicio (reposiciona y pide
  reposicionar la pelota), Poder.
- `pie.gd` (Area2D): patada con tween; hijo `DetectorDaño` (daña al rival, 10) y `DetectorPoder`.
  Emite `golpear_pelota` y `pie_contacto_pelota_en_poder`.
- Cabezazo: `comprobar_colisiones()` detecta `Pelota` tras `move_and_slide()` y emite `golpear_pelota`.
- Poderes: `CreadorPoderes` -> `Poder` (base) -> `PoderManoMagica` (vacío). Solo "mano_magica" registrado.
- IA: `ComportamientoIA` (Node hijo): cada 300 ms (REACCION_IA) sigue la x de la pelota; `configurar_decision_ia`
  vacío. Las llamadas a `process_ia()` están comentadas en los estados, así que la IA hoy no actúa.

## 7. Pelota (`Pelota`, RigidBody2D)
- `mover(normal, es_pie, fuerza)` aplica fuerza central al recibir `golpear_pelota` (conectada en EstadoPelotaNormal).
- Estados: Normal (limita velocidad máxima 3000, escucha `inicio_poder` y `reposicionar_pelota`),
  Poder (congela la física hasta `fin_poder`), Reinicio (`reset()` y vuelve a Normal).
- Reposición: `_integrate_forces` recoloca en `POSICION_INICIAL` con ángulo aleatorio según quién marcó.
- Sale de pantalla -> `estaFuera = true` (notifier) -> se recoloca.

## 8. Portería y gol
- `Porteria` (StaticBody2D): `inicializar(es_visitante)` le asigna a quién pertenece. `Red` (Area2D) emite
  `EventBus.gol(es_visitante)` si `ControladorPartido.estado_actual.gol_valido()`.
  Si la pelota está > 1 s sobre el larguero, la empuja de vuelta.
- `apariciones.gd` (en campo): instancia dos jugadores desde `jugador.tscn`, inicializa porterías y asigna
  esquemas (P1 vs IA o P1 vs P2).

## 9. UI de partido
- `ui.gd` (CanvasLayer): barras de vida y poder, marcador, nombres, iconos, reloj, textos FIN / TIEMPO EXTRA,
  animación de gol. Lee `ControladorPartido.enfrentamiento` y `DatosJugadores`.
- Poder: la barra se llena solo si `estado_actual.cargar_poder()`; al llenarse emite `poder_cargado`.
  Un gol incrementa 1/4 de la barra del rival.
- `AnimadorGol`: tween de letras; al terminar emite `fin_animacion_gol`.
- `AnimacionEnfrentamiento` (intro VS): tweens y espera ESPACIO; termina emitiendo `fin_animacion_vs`.
- `campo.gd`: oculta personajes, lanza la intro; al `fin_animacion_vs` muestra personajes y llama
  `ControladorPartido.empezar_juego()`. Al `fin_partido` arranca `FinTimer` -> vuelve al torneo si ganó el local.

## 10. Menú principal y progreso
- `MenuPrincipal`: cuatro cartas (menu, skin/personajes, estadísticas, ajustes). Foco en barra superior (`en_menu_superior`).
  `EstadoMenuPrincipal` (base) gestiona `ui_up/ui_down` para subir/bajar el foco.
- `MenuDeslizante` (carrusel): subclases `MenuDeslizanteModosJuego` (modos, `DatosModoJuego` .tres) y
  `MenuDeslizanteSeleccionPersonajes` (personajes, `DatosSeleccionPersonajes` .tres).
- Selección de modo -> `EventBus.item_selected_modos` -> `MenuPrincipal.on_item_selected_modos` crea `Torneo` y transiciona.
- `Logros`: cuadrícula de personajes (5 columnas) y vista de estadísticas; estados Eligiendo/Viendo.
- `Torneo`: bracket de 8 (jugador + 7 rivales aleatorios). `avanzar()` simula con marcadores aleatorios.
- Progreso: `InfoPersonajes` (hijo de ProgresoPartida) carga `user://progreso_personajes.json` (copia de la plantilla si no existe).
  `ProgresoPersonajes` es el modelo de cada personaje (victorias, goles, poderes desbloqueados...).

## 11. Catálogo de señales de EventBus (emisores -> receptores)
| Señal | Emite | Recibe |
|---|---|---|
| golpear_pelota(dir, es_pie, fuerza) | pie.gd, Player.gd (cabezazo), porteria.gd (larguero) | EstadoPelotaNormal -> Pelota.mover |
| pie_contacto_pelota_en_poder | pie.gd | EstadoJugadorEsperandoPoder |
| gol(es_visitante) | porteria.gd | EstadoJuegoJugando, EstadoJuegoTiempoExtra, ui.gd |
| reposicionar(es_visitante) | EstadoJuegoReseteo | EstadoJugador (base) -> pasa a REINICIO |
| reposicionar_pelota(es_visitante) | EstadoJugadorReinicio | EstadoPelotaNormal |
| poder_cargado | ui.gd | Estados Moviendo y EsperandoPoder (de ambos jugadores) |
| gastar_poder(es_visitante) | Estados Moviendo/EsperandoPoder | ui.gd |
| inicio_poder / fin_poder | (no se ha encontrado emisor) | EstadoPelotaNormal / EstadoPelotaPoder |
| cambiar_barra_vida(vida, es_visitante) | Player.gd, EstadoJugadorMoviendo | ui.gd |
| cambio_marcador(es_visitante) | ControladorPartido | ui.gd |
| fin_animacion_gol | AnimadorGol | EstadoJuegoGol |
| fin_animacion_vs | AnimacionEnfrentamiento | campo.gd |
| fin_animacion_zoom_reset | AnimacionZoom.zoom_reset | (sin receptores desde 2026-11-10; antes EstadoArcadeIsla._ready) |
| fin_animacion_nombre | AnimacionDesplazamientoNombres | EstadoLogrosViendo |
| fin_partido | EstadoJuegoFin | ui.gd, campo.gd |
| en_tiempo_extra | EstadoJuegoTiempoExtra | ui.gd |
| item_selected_personajes | BotonSeleccionPersonaje | MenuDeslizanteSeleccionPersonajes, MenuDeslizanteModosJuego, MenuPrincipal |
| item_selected_modos | MenuDeslizanteModosJuego | MenuPrincipal |
| esconder_personajes / mostrar_personajes | campo.gd | ui.gd, Player.gd, Pelota.gd |

## 12. Flujos clave
**Gol**: Pelota entra en `Red` -> `porteria` emite `gol(es_visitante)` (si el estado de juego lo permite) -> `EstadoJuegoJugando`
pasa a GOL (con el bando anotador) -> `incrementar_marcador` -> `ui` anima el gol -> `fin_animacion_gol` -> RESETEO ->
`reposicionar` -> jugadores a REINICIO (posición inicial) -> `reposicionar_pelota` -> pelota REINICIO -> NORMAL -> JUGANDO.

**Inicio de partido**: Torneo/arcade -> `JUGANDO` (campo, máquina en INACTIVO durante toda la intro) -> intro VS ->
`fin_animacion_vs` -> `empezar_juego()` -> RESETEO -> JUGANDO. Salidas (BACK o fin): `parar_juego()` -> INACTIVO.

**Fin de partido**: FIN -> `fin_partido` -> `campo.on_fin_partido` (arranca FinTimer) -> `on_transicion` ->
`gestionador_resultados.actualizar_datos_juego(datos)` (resultado por modo) -> `transicion_pantallas(
get_pantalla_asociada(modo))`. BACK a mitad de partido: en arcade -> mapa arcade en el estado `AREA`
(con contexto de isla y del nivel jugado); en el resto -> menú principal.

**Poder (previsto)**: UI llena barra -> `poder_cargado` -> jugador pulsa PODER -> estado ESPERANDO_PODER y `gastar_poder` ->
contacto de pie/cuerpo con la pelota -> estado PODER -> `poder.ejecutar()` (aún sin implementar).

## 13. Puntos a revisar (detectados al leer; verifícalos antes de actuar)
1. `menu_principal.gd`: el cuerpo de `_input` está entre comillas simples (un string), por lo que es código muerto;
   la lógica real está en `EstadoMenuPrincipal._input`.
2. `creador_estados_menu_principal.gd`: `SKIN -> Logros` y `LOGROS -> ManejadorMenuPersonajes` parecen intercambiados respecto
   a los nombres del enum.
3. `ui.gd`: `on_fin_partido(jugador, array)` tiene 2 parámetros pero `EventBus.fin_partido` no envía ninguno.
4. `estado_jugador_poder.gd`: el método se llama `_entre_tree` (typo), nunca se ejecuta; `poder.ejecutar()` no se llama.
   `PoderManoMagica` está vacío; `CreadorPoderes` solo conoce "mano_magica" mientras los JSON listan más poderes
   (el `assert` fallaría con otro).
5. IA inactiva: `comportamiento_ia.process_ia()` comentado en los estados Moviendo y EsperandoPoder.
6. `poder_cargado` no indica de qué jugador es, y `barra_poder_maximo` es una variable del estado (se reinicia a `false` en
   cada entrada); un jugador puede perder la capacidad de usar el poder tras un cambio de estado.
7. `pie.gd`: `golpeando = false` se asigna justo después de crear el tween, así que el guard `if golpeando` no protege.
8. `inicio_poder` / `fin_poder`: sin emisor encontrado; la pelota nunca entra/sale del estado PODER (?).
9. `DURACION_JUEGO_SEGUNDOS = 20` parece valor de pruebas.
10. `info_personajes.gd`: `_ready()` llama a `reiniciar_progreso()`, que borra `user://progreso_personajes.json` en cada arranque
    (el progreso no persiste entre ejecuciones).
11. Archivos `.tmp` sueltos en `Escenas/pantallas/` (copias de seguridad de Godot) que conviene borrar o ignorar en git.
12. `.git` pesa >100 MB (pack grande): conviene revisar qué assets pesados se versionaron (?).
13. Convenciones de nombre irregulares: carpetas con espacios (`estados pelota`, `estados menu principal`) y mayúsculas
    mezcladas (`Animaciones`, `ControladorJuego` frente a `jugador`, `utils`); ficheros `Player.gd`, `Pantallatorneo.gd`.
    Renombrarlos desde el sistema de archivos rompe las rutas `ext_resource` de las escenas: hacerlo desde el editor Godot.
14. Desviaciones del patrón de máquina de estados: `ControladorPartido`/`EstadoJuego` usan la señal
    `peticion_transmitir_estado` (el resto del proyecto: `peticion_transmision_estado`); `Player.gd` y
    `controlador_partido.gd` conectan con `.bind()` sin argumentos mientras menú y logros conectan directos.
15. `.gitignore` solo cubre `.godot/` y `/android/`: `.opencode/` (contiene ~2500 ficheros de `node_modules`) está sin
    ignorar y aparece como `??`. Añadir `.opencode/` antes del próximo commit.
16. IA jamás se activa, aunque se descomente `process_ia()`: `controlador_partido.setup_jugador` no es `@export` y nadie
    le asigna valor, así que `jugando_solitario()` (que lee `setup_jugador[1].is_empty()`) es siempre false con el
    default `["MarkEvans","AxelBlaze"]` -> `apariciones.gd` pone P2, nunca `ControlScheme.IA`. Hay dos fuentes de verdad
    en conflicto: `setup_jugador` vs `enfrentamiento.config_jugador_visitante`.
17. Descomentar `process_ia()` tampoco movería a la IA: la rama IA de `_process` en los estados no hace `move_and_slide`,
    ni gravedad, ni animación, ni las comprobaciones de transición (vida <= 0, poder); y `KeyUtils.MAPA_ACCIONES` no
    tiene entrada para `ControlScheme.IA`, por lo que `movimiento_general()` fallaría con "key not found".
18. `Menu.tscn` tiene 5 placeholders pero `MenuDeslizante.visible_slots` por defecto es 7: se corrigió poniendo
    `visible_slots = 5` en el nodo `manejador` (el que lleva `menu_deslizante_modos_juego.gd`). La raíz `MenuDeslizante`
    NO debe llevar script de estado: el estado se crea con `.new()` desde el Creador.
19. `logros.gd` y `manejador_menu_personajes.gd` decían `extends Node` pero sus raíces de escena son `Control`: sin
    `extends Control`, las llamadas `.show()/.hide()` desde `menu_principal.gd` (variables tipadas) no compilaban.
20. La máquina de estados del partido es hija del autoload `ControladorPartido`, así que **seguía viva entre partidos**:
    nada la detenía al salir de `campo` (BACK no llamaba a `cambiar_estado`) y `tiempo_restante` solo se reseteaba en
    `_ready` y en `empezar_juego()` (tras la intro VS, al pulsar ESPACIO). Si el reloj llegaba a 0 "en segundo plano"
    con marcador empatado, la máquina quedaba en TIEMPO_EXTRA (o emitía `fin_partido`/`en_tiempo_extra` con la nueva
    pantalla ya cargada) → síntoma: la partida parecía iniciarse en tiempo extra (texto "TIEMPO EXTRA" visible).
    **Corregido** (2026-11-08): estado INACTIVO + `parar_juego()` al entrar/salir de `campo` (ver sección 5).
21. `Scripts/GestionadorResultadosPartido/` (revisado y **corregido** el 2026-11-08):
    Se degradó de "máquina de estados" a **estrategia `RefCounted`**: se eliminaron señal, `connect`,
    `add_child` diferido, `queue_free` y nombre de nodo (código muerto con tipos erróneos de `EstadoJuego`
    y señal con 2 argumentos frente a 1 en el handler; el manager era un `Node` nunca añadido al árbol ->
    fuga de memoria por partido). Correcciones de lógica:
    (a) el estado de torneo ahora ejecuta `set_partido_personaje_actual`/`set_perdido` (condición `!=`)
    y devuelve el MISMO `datos_pantalla` (antes devolvía `DatosPantallas.new()` y `Pantallatorneo._ready`
    recibía `torneo = null`; la progresión del bracket no se ejecutaba);
    (b) el estado de arcade ya no toca `datos_pantalla.torneo` (es null en modo arcade -> error en runtime)
    y usa `completar_nivel_arcade()` (antes nadie lo llamaba) con condición `==` (completo si GANO) sobre el
    contexto `isla_arcade`/`nivel_arcade` que `DatosPantallas` lleva de ida (`estado_arcade_area`) y vuelta;
    (c) base passthrough + fallback en `get_fresh_state` para los 6 modos sin estado (el default anterior
    devolvía `DatosPantallas.new()`, la misma trampa del null);
    (d) `arcade._ready` restaura `isla_actual` desde el contexto (antes volvía siempre a RAIMON);
    (e) BACK en modo arcade vuelve al mapa arcade en vez del menú principal.
    Fuera de alcance (sigue pendiente): `desbloquear_isla_arcade()` (`info_general.gd:115`) sigue sin llamante.

22. `null` al reiniciar un partido arcade tras BACK (detectado 2026-11-08, **corregido**): `campo` hace
    `enfrentamiento = Enfrentamientos.new()` en la rama BACK -> el jugador local queda con `jugador = ""`.
    Antes no se notaba porque BACK volvía al menú y `menu_principal.on_item_selected_modos` (línea 60)
    reponía el local; con BACK -> mapa arcade ese paso se saltaba y `estado_arcade_area` solo ponía el
    visitante -> `apariciones.gd` llamaba `DatosJugadores.get_jugador("")` -> null -> `Player.inicializar`
    accedía a `jugador_data.nombre` (`Player.gd:88`). **Corregido**: `estado_arcade_area` (rama
    `ui_accept`) pone también el local desde el progreso antes de transicionar; el reset de BACK se
    mantiene. El mismo día se cambió la regla de animación a por-origen (sección 2).

23. `estado_arcade.gd` tiene `print()` de diagnóstico **temporales** (`_diagnostico_bloqueo` y el de
    `escena_lista = true`) para probar el candado de input (sección 2): borrarlos cuando se confirme
    que funciona. Idioma de los mensajes: español.

24. `EstadoMenuPrincipal._enter_tree` (línea 35) repite el patrón `await mostrar_escena()` de la base
    arcade, pero **sin candado de input**: el menú acepta teclas mientras su `mostrar_escena()` corre
    (y aquí casi todas las implementaciones son síncronas, así que el await es realmente redundante —
    produce el aviso `redundant_await` que en arcade se silenció con `@warning_ignore`). Decisión
    2026-11-10: fuera de alcance, no tocar `EstadoMenuPrincipal`.

25. `EventBus.fin_animacion_zoom_reset` quedó **sin receptores** al mover el fundido de identificadores
    de ISLA dentro de `EstadoArcadeIsla.mostrar_escena()` con await (sección 2). El `emit()` sigue en
    `AnimacionZoom.zoom_reset()` (línea 33): se puede eliminar la señal y el emit si no se planea
    reutilizar.


## Balance del jugador (2026-11-12)
Esta secci?n sustituye los valores y observaciones anteriores sobre estad?sticas, retroceso y se?al de carga.
- `GestorEstadisticas`: puntuaciones limitadas a 0..10, base 5. Velocidad: 500 + (s-5)*28 px/s; salto: interpolacion de 15.28065 a 32.8533975 px para s=0..4; 64.688085 + (s-5)*31.8346875 px para s >= 4; power: 20 - (s-5)*1.2 segundos de recarga; aguante: 210 - (s-5)*18 px de retroceso objetivo.
- L?mites respectivos: 360..640 px/s, 15.28065..223.8615225 px, 14..26 s, 120..300 px. Tambi?n se aplican a valores modificados. `modificar()` sigue sumando unidades f?sicas, no puntos de la ficha; vida conserva el da?o existente. Inicializar limpia modificaciones anteriores.
- `get_velocidad_salto()` convierte la altura en impulso negativo con sqrt(2*g*h). Gravedad propia del jugador: 2*220/0.35? (~3592 px/s?), sin modificar la pelota. Ya no se almacena `velocidad_maxima_subida`.
- Moviendo, EsperandoPoder y Aturdido actualizan f?sica en `_physics_process`. Movimiento horizontal con respuesta y frenado inmediatos.
- Aturdido: velocidad inicial horizontal calculada con sqrt(2*4000*distancia); frenado 4000 px/s? multiplicado por delta, independiente de velocidad. Conserva velocidad vertical. Aturdimiento fijo 0.7 s. Distancia aproximada, afectada por paso f?sico y colisiones.
- `BarraPoder`: capacidad fija 100, tasa 100/segundos_recarga; bonus por recibir gol de 25. La UI env?a `EventBus.poder_cargado(es_visitante: bool)` solo al llenarse la barra correspondiente.
- `Jugador.poder_listo` conserva disponibilidad entre estados, escucha poder_cargado y gastar_poder filtrando por bando. Los estados consultan esta propiedad y ya no guardan su propia bandera ni escuchan poder_cargado.
- Validaci?n: carga de scripts en Godot 4.7.1 y prueba aislada de valores 0/3/5/10, conversi?n de salto, recarga/bonus/reset y l?mites de modificaciones. Pendiente evaluar sensaciones y balance en partidas reales.

- Ajuste vigente de salto: referencia de capsula 114.2 px, media de las 10 alturas positivas de jugadores.json (104..122 px); se excluyen 8 fichas con altura 0. Desplazamiento vertical para estadistica 0/3/4/5/10: 15.28065/28.460210625/32.8533975/64.688085/223.8615225 px. Sumando la capsula media, nivel 4 alcanza 147.0533975 px y nivel 10 alcanza 338.0615225 px tras tres aumentos del 5% y otro del 10% (factor acumulado 1.2733875). Se conserva la gravedad. Es una calibracion media, no una compensacion individual: el alcance cambia con el tamano real, la integracion fisica y las colisiones. La capsula tampoco garantiza el limite exacto del sprite visible.


## Logros por nivel arcade
- Cada entrada de `ProgresoArcade.progreso_por_jugador[personaje][isla]["jugadores"][rival_nivel]` contiene ahora `{"vencido": false, "logros_arcade": [false, false, false]}`. Cada nivel tiene su propio array.
- `deserialize` convierte booleanos antiguos a este formato conservando las victorias; rellena logros ausentes con false y conserva los ya conseguidos. Las consultas de victorias y el recuento de niveles usan `vencido`.
- `InfoGeneral.get_logros_arcade(isla, rival, nivel)` devuelve un Array[bool] independiente para el personaje seleccionado. Nivel usa exclusivamente 0 o 1 por rival. No evalua ni desbloquea misiones.
- `InfoGeneral._ready` ya no reinicia el progreso al arrancar; crea la plantilla solo si no existe y carga el JSON existente. `reiniciar_progreso` sigue disponible para reinicio explicito. El formato nuevo se escribe con `guardar_progreso()`.

- `GestorLogrosArcade` es RefCounted. Se crea por partido con isla, rival y nivel local 0/1, y captura el personaje seleccionado. Los diccionarios usan ID int: islas 0..7, generales 100 (ganar sin tiempo extra) y 101 (marcar 5 goles). Los contadores pendientes se reinician por instancia; los logros previos se cargan del progreso.
- Orden persistido: [GANAR_SIN_TIEMPO_EXTRA, METER_5_GOLES, logro de isla]. Los textos respetan ese orden y Meter5Goles tiene objetivo 5. Las condiciones especificas de isla siguen pendientes de definicion; no se conceden automaticamente.
- `evaluar_logros()` agrupa todos los desbloqueos en una llamada a InfoGeneral. `ProgresoArcade.set_logros_arcade()` fusiona mediante OR y devuelve si hay nuevos true. InfoGeneral escribe en disco solo cuando hay nuevos desbloqueos; una repeticion peor nunca elimina estrellas.
- El mapa y DatosPantallas mantienen indices globales. `ProgresoArcade.get_nivel_rival(isla, indice)` convierte con floor(indice / cantidad_rivales) a 0/1. El gestor, InfoNivel y resultado arcade aplican esta conversion antes de consultar/escribir progreso. El JSON solo usa rival_0 y rival_1.
- Migracion version_niveles=2 por isla: conserva valores locales y fusiona claves globales mediante OR; elimina claves sobrantes. Algunas claves antiguas 0/1 son ambiguas al coexistir formatos, por lo que se prioriza conservar logros. InfoGeneral conserva un .antes_niveles_locales.bak antes de escribir el JSON migrado.
- `evaluar_logros` guarda si cambios > 0; comparar con Array.size() era incorrecto porque siempre vale 3. Los indicadores del mapa reciben ahora el array real con set_logros; antes siempre mostraban cero estrellas por el argumento por defecto de inicializar.
- Prueba aislada de Godot: generacion de claves 0/1, conversion de mapa, migracion de claves globales, recarga y union monotona de logros.
- EstadoArcadeArea actualiza InfoNivel.setup en cada seleccion, despues de restaurar el indice al volver al mapa.
- Campo.on_fin_partido procesa el resultado inmediatamente antes del FinTimer. GestionadorResultadosPartidos usa resultado_procesado para impedir dobles evaluaciones. Solo confirma resultados en EstadoJuegoFin; el reloj a cero por si solo no basta (tiempo extra).
- EstadoResultadoPartidoArcade registra la victoria sin tiempo extra solo cuando gana el local, registra goles locales y evalua. Maneja gestor null y contexto NONE. Las victorias generales de personaje se incrementan solo al ganar.
- BACK de Campo delega en GestionadorResultadosPartidos.gestionar_back(campo): detiene timer, confirma FIN si falta, para el partido, limpia contexto temporal y vuelve al mapa arcade o menu. salida_iniciada evita transiciones duplicadas. El gestor RefCounted se libera al limpiar la referencia.
- Validacion en copia aislada de Godot 4.7.1: IDs, umbral de cinco goles, guardado/carga JSON, catalogo de niveles, derrota sin tiempo extra, repeticion, union de logros y BACK antes/despues de FIN. No se ha probado visualmente la UI. Godot tambien reporta avisos preexistentes de mayusculas en Pelota.tscn y recursos pendientes al cerrar la prueba.



## Contrato del marcador
- Todo el recorrido gol -> estados -> incrementar_marcador -> aumentar_marcador -> cambio_marcador -> UI y reposicion transmite `es_visitante: bool`: false identifica al anotador local, true al visitante. Se corrige la firma String que quedaba en ControladorPartido.
- `Porteria.es_visitante` identifica al anotador; apariciones configura true en porteria_local y false en porteria_visitante. Solo Pelota puede producir un gol.
- Los receptores on_gol de Jugando y TiempoExtra ignoran eventos si ya no son el estado actual, aunque queue_free aun no los haya eliminado.


## Navegacion de logros del menu
- EstadoMenuPrincipalLogros abre siempre ELIGIENDO con indice 0; ocultarlo retira el foco.
- BACK desde VIENDO pasa el ultimo indice consultado mediante DatosEstadoLogros. ELIGIENDO selecciona ese personaje, sincronizando coordenadas globales/visibles, filas, scroll y marco.
- Al reposicionar se cancelan tweens anteriores de marco y scroll; al salir de VIENDO se detiene el tween de flechas y se desconecta fin_animacion_nombre. Solo recibe input el estado actual con panel visible y foco.
- Verificado en Godot con la escena real: BACK tras avanzar de personaje, seleccion del ultimo personaje con scroll y reapertura en ELIGIENDO. Eliminadas referencias onready sin uso a %equipo y %imagen, nodos inexistentes en Pantallalogros.
