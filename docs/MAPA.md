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
- Animaciones de transición (`AnimationPlayer` de `head_soccer.tscn`): `CreadorAnimacionesPantallas.
  get_fresh_animacion(origen, destino)` consulta un dict `destino -> { origen -> animación }` — sin entrada
  para el origen, cambio instantáneo. Hoy solo ARCADE tiene animación (`nubes`) y solo si el origen es
  `MENU_PRINCIPAL` (no al volver de `JUGANDO`); el origen lo recuerda `HeadSoccer.pantalla_cargada`.

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
- `Porteria` (StaticBody2D): `inicializar(jugador)` le asigna a quién pertenece. `Red` (Area2D) emite
  `EventBus.gol(jugador)` si `ControladorPartido.estado_actual.gol_valido()`.
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
| gol(jugador) | porteria.gd | EstadoJuegoJugando, EstadoJuegoTiempoExtra, ui.gd |
| reposicionar(jugador) | EstadoJuegoReseteo | EstadoJugador (base) -> pasa a REINICIO |
| reposicionar_pelota(anotador) | EstadoJugadorReinicio | EstadoPelotaNormal |
| poder_cargado | ui.gd | Estados Moviendo y EsperandoPoder (de ambos jugadores) |
| gastar_poder(es_visitante) | Estados Moviendo/EsperandoPoder | ui.gd |
| inicio_poder / fin_poder | (no se ha encontrado emisor) | EstadoPelotaNormal / EstadoPelotaPoder |
| cambiar_barra_vida(vida, es_visitante) | Player.gd, EstadoJugadorMoviendo | ui.gd |
| cambio_marcador(anotador) | ControladorPartido | ui.gd |
| fin_animacion_gol | AnimadorGol | EstadoJuegoGol |
| fin_animacion_vs | AnimacionEnfrentamiento | campo.gd |
| fin_animacion_nombre | AnimacionDesplazamientoNombres | EstadoLogrosViendo |
| fin_partido | EstadoJuegoFin | ui.gd, campo.gd |
| en_tiempo_extra | EstadoJuegoTiempoExtra | ui.gd |
| item_selected_personajes | BotonSeleccionPersonaje | MenuDeslizanteSeleccionPersonajes, MenuDeslizanteModosJuego, MenuPrincipal |
| item_selected_modos | MenuDeslizanteModosJuego | MenuPrincipal |
| esconder_personajes / mostrar_personajes | campo.gd | ui.gd, Player.gd, Pelota.gd |

## 12. Flujos clave
**Gol**: Pelota entra en `Red` -> `porteria` emite `gol(jugador)` (si el estado de juego lo permite) -> `EstadoJuegoJugando`
pasa a GOL (con anotador) -> `incrementar_marcador` -> `ui` anima el gol -> `fin_animacion_gol` -> RESETEO ->
`reposicionar` -> jugadores a REINICIO (posición inicial) -> `reposicionar_pelota` -> pelota REINICIO -> NORMAL -> JUGANDO.

**Inicio de partido**: Torneo/arcade -> `JUGANDO` (campo, máquina en INACTIVO durante toda la intro) -> intro VS ->
`fin_animacion_vs` -> `empezar_juego()` -> RESETEO -> JUGANDO. Salidas (BACK o fin): `parar_juego()` -> INACTIVO.

**Fin de partido**: FIN -> `fin_partido` -> `campo.on_fin_partido` (arranca FinTimer) -> `on_transicion` ->
`gestionador_resultados.actualizar_datos_juego(datos)` (resultado por modo) -> `transicion_pantallas(
get_pantalla_asociada(modo))`. BACK a mitad de partido: en arcade -> mapa arcade (con contexto de isla);
en el resto -> menú principal.

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
