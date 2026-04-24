extends Node

# === SEÑALES ===
signal jugador_selecciona_enemigo()
signal ataque_iniciado()
signal turno_cambiado(turno)
signal defensa_elegida
signal combate_terminado(victoria: bool)

var ui
var defensa_ui
var jugador
var muerte_ui

var turno_jugador : bool = true
var ejecutando_turno_enemigo := false #Flag 
var turno_actual : int = 1
var puede_abrir_menu : bool = true

var personaje_seleccionado #---Jugador
var personaje_objetivo #---Enemigo elegido para atacar
var enemigos : Array = []

var habilidad_actual
var dialogue_balloon


# INIT =====================================================================
func inicializar_referencias(_jugador, _ui):
	jugador = _jugador
	ui = _ui
	defensa_ui = ui.get_node("Turnos_defensa/Control/DefensaUi")
	muerte_ui = ui.get_node("GameOver")
	dialogue_balloon = ui.get_node("Dialogue")
	
	# VIDA
	if not jugador.stats.vida_cambiada.is_connected(_on_vida_cambiada):
		jugador.stats.vida_cambiada.connect(_on_vida_cambiada)
	_on_vida_cambiada(jugador.stats.Vida_actual, jugador.stats.Vida_maxima)
	
	# ACCIONES
	if not jugador.acciones_cambiadas.is_connected(_on_acciones_cambiadas):
		jugador.acciones_cambiadas.connect(_on_acciones_cambiadas)
	_on_acciones_cambiadas(jugador.acciones_actuales)
	
	# TURNOS
	emit_signal("turno_cambiado", turno_actual)
	
	# ===== CONCENTRACION =====
	# conectar señal
	if not jugador.stats.concentracion_cambiada.is_connected(_on_concentracion_cambiada):
		jugador.stats.concentracion_cambiada.connect(_on_concentracion_cambiada)
	# crear UI (ojos)
	ui.crear_concentracion(jugador.stats.Concentracion_maxima)
	# inicializar estado real
	jugador.stats.emitir_concentracion()
	# ===== CORDURA =====
	if not jugador.stats.cordura_cambiada.is_connected(_on_cordura_cambiada):
		jugador.stats.cordura_cambiada.connect(_on_cordura_cambiada)
	ui.actualizar_cordura(jugador.stats.Cordura_actual)
# =========================================================================



# ====== MANEJO DE TURNOS =====
# =============================
func cambiar_turno():
	print("---- CAMBIO DE TURNO ----")
	print("Antes -> turno_jugador:", turno_jugador)
	if ejecutando_turno_enemigo:
		return
	
	turno_jugador = !turno_jugador
	print("Después -> turno_jugador:", turno_jugador)
	
	# ===== TURNOS =====
	if turno_jugador:
		turno_actual += 1
		emit_signal("turno_cambiado", turno_actual)
		puede_abrir_menu = true
		
		jugador.set_posicion(Personaje.Posicion.CENTRO)
		jugador.defendiendo = false
	else:
		ejecutar_turno_enemigos()
	
	# ===== CONCENTRACION =====
	if jugador and jugador.stats:
		jugador.stats.actualizar_bloqueos()

func ejecutar_turno_enemigos():
	print(">>> INICIA TURNO ENEMIGOS")
	ejecutando_turno_enemigo = true
	
	for enemigo in enemigos:
		await get_tree().create_timer(1.0).timeout
		await enemigo.turno_enemigo()
		await get_tree().create_timer(1.0).timeout
	
	ejecutando_turno_enemigo = false
	print("<<< TERMINA TURNO ENEMIGOS")
	cambiar_turno() # vuelve al jugador

# =======DEFENSA===============
func mostrar_defensa():
	defensa_ui.visible = true

func ocultar_defensa():
	defensa_ui.visible = false

func esperar_defensa():
	mostrar_defensa()
	print(">>> ESPERANDO DECISION DEL JUGADOR")
	await self.defensa_elegida
	ocultar_defensa()
	print("<<< DECISION RECIBIDA")
# ============================
# ============================


func mostrar_seleccion():
	puede_abrir_menu = false
	emit_signal("jugador_selecciona_enemigo")

func establecer_personaje(personaje):
	personaje_seleccionado = personaje

func establecer_objetivo(personaje):
	personaje_objetivo = personaje

func iniciar_ataque(usos := 0) -> void:
	emit_signal("ataque_iniciado")
	print("Usando habilidad:", habilidad_actual.nombre)
	print("Objetivo:", personaje_objetivo)
	print("Enemigos:", enemigos.size())
	
	# ===== VALIDACION (SOLO JUGADOR) =====
	if personaje_seleccionado.stats.jugador:
		if not habilidad_actual.puede_usarse(personaje_seleccionado.stats):
			print("No se puede usar la habilidad")
			puede_abrir_menu = true
			return
	
	# ===== TURNO ENEMIGO (AQUI VA DEFENSA) =====
	if not personaje_seleccionado.stats.jugador:
		#print("El enemigo va a atacar...")
		print("Pista: ataque en posiciones -> ", habilidad_actual.posiciones_que_golpea)
		
		print("ID dialogo: ", habilidad_actual.id_dialogo)
		await mostrar_dialogo( #Aqui pausamos para ver el dialogo de pista
		habilidad_actual.ruta_dialogo,
		habilidad_actual.id_dialogo,
		usos)
		await esperar_defensa() #Aqui se pausa todo
	
	# ===== EJECUCION =====
	habilidad_actual.ejecutar(personaje_seleccionado, personaje_objetivo, enemigos)
	
	if personaje_objetivo:
		print(personaje_objetivo.stats.Vida_actual)

	# ===== FINALIZAR =====
	if personaje_seleccionado.stats.jugador: 
		personaje_seleccionado.finalizando_ataque()


# === CAMBIOS DEL UI ========
func _on_vida_cambiada(actual, maximo):
	ui.actualizar_barra_jugador(actual, maximo)

func _on_acciones_cambiadas(disponibles):
	ui.actualizar_acciones(disponibles)

# ===== CONCENTRACION =====
func _on_concentracion_cambiada(actual, maximo):
	ui.actualizar_concentracion(actual)
# =========================

# ===== CORDURA ===========
func _on_cordura_cambiada(actual, maximo):
	ui.actualizar_cordura(actual)
# =========================

func remover_enemigo(enemigo):
	enemigos.erase(enemigo)
	print("Enemigos restantes:", enemigos.size())

	if enemigos.size() == 0:
		print("Victoria!")
		finalizar_combate(true)
		# Aquí luego puedes poner pantalla de victoria

func finalizar_combate(victoria: bool):
	print("=== FIN DEL COMBATE ===")
	
	limpiar_enemigos()
	
	emit_signal("combate_terminado", victoria)

func jugador_muerto():
	print("GAME OVER")
	mostrar_game_over()

func mostrar_game_over():
	muerte_ui.visible = true
	get_tree().paused = true

func mostrar_dialogo(ruta: String, id: String, usos: int):
	if ruta == "":
		return
	
	var recurso = load(ruta) as DialogueResource
	
	var contexto = {
		"usos": usos
	}
	
	dialogue_balloon.start(recurso, id, [contexto])
	dialogue_balloon.visible = true
	
	await dialogue_balloon.finished
	
	dialogue_balloon.visible = false

# ==== CAMBIOS DE COMBATE ====
func iniciar_combate(_jugador, combat_data: CombatData):
	print("=== INICIANDO COMBATE ===")
	
	jugador = _jugador
	
	# limpiar enemigos anteriores
	limpiar_enemigos()
	
	# aplicar fondo si UI lo maneja
	if ui:
		ui.cambiar_fondo(combat_data.fondo)
	
	# instanciar enemigos
	for spawn in combat_data.spawns:
		var enemigo = spawn.escena_enemigo.instantiate()
		
		enemigo.data = spawn.enemigo
		
		
		add_child(enemigo)
		enemigo.inicializar() # CRÍTICO
		enemigo.global_position = spawn.posicion
	
	# reset estado combate
	turno_jugador = true
	turno_actual = 1
	ejecutando_turno_enemigo = false
	
	emit_signal("turno_cambiado", turno_actual)

func limpiar_enemigos():
	for e in enemigos:
		if is_instance_valid(e):
			e.queue_free()
	
	enemigos.clear()
