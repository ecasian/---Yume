extends Node2D
class_name Personaje

@export var stats: Stats
@export var medic: Array[Medicamentos]
@export var habilidades_magicas: Array[Habilidad]
@export var habilidades_arma: Array[Habilidad]

@onready var animacion: AnimatedSprite2D = $Animacion

#==== SEÑALES ====
signal acciones_cambiadas(disponibles)

var personaje_objetivo
var acciones_max : int
var acciones_actuales : int

enum Posicion {
	IZQUIERDA, # 0
	DERECHA,   # 1
	CENTRO,    # 2
	AGACHADO   # 3
}

var posicion_actual = Posicion.CENTRO
var defendiendo = false

func _ready():
	if stats != null:
		if not stats.vida_cero.is_connected(_on_muerte):
			stats.vida_cero.connect(_on_muerte)
	else:
		print("Personaje sin stats aún (esperando inicialización)")

	animacion.play("Idle")

	if stats and stats.jugador:
		Manager.jugador = self

	if stats:
		calcular_acciones()
		acciones_actuales = acciones_max
		emit_signal("acciones_cambiadas", acciones_actuales)

func _on_panel_gui_input(event):
	if stats.jugador:
		if Input.is_action_just_pressed("mouse_izquierdo") and Manager.puede_abrir_menu and Manager.turno_jugador:
			
			var ui = $"../UI"
			
			# ===== ABRIR MENU =====
			ui.abrir_menu(self)  #ahora pasamos el jugador
			
			# ===== LIMPIAR =====
			ui.limpiar_listas()
			
			# ===== GENERAR OPCIONES DINAMICAS =====
			# ===== MAGICAS =====
			for h in habilidades_magicas:
				ui.agregar_habilidad(h)
			# ===== FISICAS =====
			for h in habilidades_arma:
				ui.agregar_accion_arma(h)
			
			# ===== IMPORTANTE =====
			Manager.establecer_personaje(self)

	else:
		if Input.is_action_just_pressed("mouse_izquierdo") and $Seleccionar.visible:
			Manager.establecer_objetivo(self)
			Manager.iniciar_ataque()


func atacar_personaje(target):
	personaje_objetivo = target
	finalizando_ataque()

#--- Acciones del enemigo ---
func mostrar_seleccion():
	$Seleccionar.visible = true

func ocultar_seleccion():
	$Seleccionar.visible = false

func finalizando_ataque():
	acciones_actuales -= 1
	emit_signal("acciones_cambiadas", acciones_actuales)
	print("Acciones restantes: ", acciones_actuales)
	personaje_objetivo = null

	
	if acciones_actuales <= 0:
		terminar_turno()
	else:
		Manager.puede_abrir_menu = true

func terminar_turno():
	print("Turno terminado")

	acciones_actuales = acciones_max
	emit_signal("acciones_cambiadas", acciones_actuales)
	Manager.cambiar_turno()

# --- Calculamos las acciones que puede hacer el jugador ---
func calcular_acciones():
	if stats.Velocidad >= 25:
		acciones_max = 3
	elif stats.Velocidad >= 15:
		acciones_max = 2
	else:
		acciones_max = 1

func set_posicion(nueva_pos):
	posicion_actual = nueva_pos
	print("Jugador ahora está en:", posicion_actual)

func _on_muerte():
	print(name, " ha muerto")

	if not stats.jugador:
		Manager.remover_enemigo(self)
		queue_free()
	else:
		Manager.jugador_muerto()


"""
---> Depurador rudimentario inicial... cambiado el 04/04/26
func _ready():
	if stats == null:
		push_error("Stats es null antes de duplicar")
		return
	stats = stats.duplicate(true) # Es necesario duplicar los stas para evitar futuros errores
	print("Vida maxima: ", stats.obtener_estadisticas(&"Vida_maxima") ) 
	print("Vida actual: ", stats.Vida_actual) 
	print("Cordura maxima: ", stats.obtener_estadisticas(&"Cordura_maxima")) 
	print("Cordura actual: ", stats.Cordura_actual) 
	print("Concentración: ", stats.obtener_estadisticas(&"Concentracion")) 
	print("Fuerza: ", stats.obtener_estadisticas(&"Fuerza")) 
	print("Afinidad E: ", stats.obtener_estadisticas(&"Af_E")) 
	print("Resistencia Fisica: ", stats.obtener_estadisticas(&"Res_F")) 
	print("Resistencia E: ", stats.obtener_estadisticas(&"Res_E")) 
	print("Iluminación: ", stats.Iluminacion) 
	print("Velocidad: ", stats.obtener_estadisticas(&"Velocidad")) 
	
	stats.recibir_danio(20.0)
	print("Vida actual: ", stats.Vida_actual)
	medic[0].usar(self)
	#stats.curar(30.0)
	print("Vida actual: ", stats.Vida_actual)
	
	#stats.añadir_modificador("Velocidad", 10)
	#var new = stats.obtener_estadisticas("Velocidad")
	#print("Nuevo: ", new)
	#print("Nueva velocidad: ", stats.Velocidad)
	
	#--- Depurador nuevo
	--stats.bloquear_concentracion(2, 3)
	--stats.recibir_danio(55.0)
			
	if stats.Vida_actual <= 0:
		muerte() 

func muerte() -> void:
	print("Estas muerto")
	#queue_free() Solo usar en enemigos, cuando son eliminados para desaparecer su nodo de pantalla
"""
"""
func usar_medicamento(nombre: StringName):
	for m in medic:
		if m.fuente == nombre:
			m.usar(self)
			return
"""

#--- Cosas que faltan de agregar ---
# Sistema de habilidades
# Consumibles
