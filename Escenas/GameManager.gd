extends Node

# ===== ESTADO =====
enum EstadoJuego {
	EXPLORACION,
	DIALOGO,
	COMBATE
}

var estado_actual = EstadoJuego.EXPLORACION

# ===== REFERENCIAS =====
var jugador
var ui

# ===== ESCENARIO =====
var escenario_actual : Escenario

var ubicaciones := {}
var ubicacion_actual : Ubicacion

# ===== PROGRESO =====
var estado_ubicaciones := {}
var stats_jugador_persistente : Stats

# =========================
# ===== INIT ==============
# =========================
func inicializar(_jugador, _ui):
	jugador = _jugador
	ui = _ui
	
	#SI NO EXISTEN, CREARLOS
	if stats_jugador_persistente == null:
		stats_jugador_persistente = jugador.stats
	#SI EXISTEN, REUTILIZARLOS
	jugador.stats = stats_jugador_persistente
	
	escenario_actual = load("res://Escenas/Mundo/Escenario_1/Escenario_1.tres")
	
	cargar_escenario(escenario_actual)

# =========================
# ===== ESCENARIO =========
# =========================
func cargar_escenario(escenario: Escenario):
	ubicaciones.clear()
	
	for u in escenario.lista_ubicaciones:
		ubicaciones[u.id] = u
	
	cambiar_ubicacion(escenario.ubicacion_inicial)

# =========================
# ===== UBICACION =========
# =========================
func cambiar_ubicacion(id: String):
	if not ubicaciones.has(id):
		print("Ubicación no encontrada:", id)
		return
	
	estado_actual = EstadoJuego.DIALOGO
	
	ubicacion_actual = ubicaciones[id]
	print("Entrando a:", ubicacion_actual.nombre_lugar)
	
	# ===== VISUAL =====
	if ui:
		ui.cambiar_fondo(ubicacion_actual.fondo)
	
	await procesar_entrada_ubicacion()
	
	estado_actual = EstadoJuego.EXPLORACION

# =========================
# ===== ENTRADA ===========
# =========================
func procesar_entrada_ubicacion():
	var estado = obtener_estado_actual()
	
	# ===== DIALOGO =====
	if ubicacion_actual.ruta_dialogo != "":
		await ui.mostrar_dialogo(ubicacion_actual.ruta_dialogo)
	
	# ===== COMBATE =====
	if ubicacion_actual.combate and not estado.get("combate_completado", false):
		
		if ubicacion_actual.combate_obligatorio:
			await entrar_combate(ubicacion_actual.combate)
			estado["combate_completado"] = true

# =========================
# ===== COMBATE ===========
# =========================
func entrar_combate(combate_data):
	if combate_data == null:
		print("No hay combate definido")
		return
		
	estado_actual = EstadoJuego.COMBATE
	
	var id_guardado = ubicacion_actual.id
	
	get_tree().change_scene_to_file("res://Escenas/Combate/Combate.tscn")
	await get_tree().process_frame
	
	Manager.iniciar_combate(jugador, combate_data)
	var resultado = await Manager.combate_terminado
	
	await salir_combate(id_guardado)

func salir_combate(id_retorno):
	get_tree().change_scene_to_file("res://Escenas/Mundo/Main.tscn")
	await get_tree().process_frame
	await get_tree().process_frame 
	
	# Dejar que Main reinicialice todo
	await cambiar_ubicacion(id_retorno)

func combate_actual():
	entrar_combate(ubicacion_actual.combate)

# =========================
# ===== ESTADO ============
# =========================
func obtener_estado_actual():
	var id = ubicacion_actual.id
	
	if not estado_ubicaciones.has(id):
		estado_ubicaciones[id] = {
			"combate_completado": false,
			"npc_hablado": false
		}
	
	return estado_ubicaciones[id]
