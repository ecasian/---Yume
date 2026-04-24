extends CanvasLayer

#==== REFERENCIAS ====
@onready var barra_vida_jugador: ProgressBar = $MargenUIStats/Contenedor/VidaContainer/BarraVidaJugador
@onready var contenedor_concentracion: HBoxContainer = $MargenUIStats/Contenedor/ContenedorConcentracion
@onready var barra_cordura = $MargenUIStats/Contenedor/CorduraContainer/BarraCordura
@onready var label_cordura = $MargenUIStats/Contenedor/CorduraContainer/CorduraLabel

@onready var panel_descripcion = $PanelDescripcion
@onready var nombre = $PanelDescripcion/MarginContainer/VBoxContainer/Nombre
@onready var descripcion = $PanelDescripcion/MarginContainer/VBoxContainer/Descripcion
@onready var costo = $PanelDescripcion/MarginContainer/VBoxContainer/Costo

@onready var menu_izquierda = $MenuIzquierda
@onready var lista_habilidades = $MenuIzquierda/ListaHabilidades

@onready var menu_derecha = $MenuDerecha
@onready var lista_arma = $MenuDerecha/ListaArma


@onready var label_turnos = $Turnos_acciones/Panel/VBoxContainer/TurnosLabel
@onready var label_acciones = $Turnos_acciones/Panel/VBoxContainer/AccionesLabel
#=====================

var textura_ojo_abierto = preload("res://Assets/Iconos/Concentracion_A.png")
var textura_ojo_cerrado = preload("res://Assets/Iconos/Concentracion_C.png")

var ojos = []

func _ready():
	Manager.connect("turno_cambiado", actualizar_turno)

#==== ESTADO ====
var habilidad_seleccionada = null
var jugador_actual = null 

# ==== UI STATS ====
func actualizar_barra_jugador(actual, maximo):
	barra_vida_jugador.max_value = maximo
	barra_vida_jugador.value = actual

func crear_concentracion(max_concentracion):
	for hijo in contenedor_concentracion.get_children():
		hijo.queue_free()
		
	ojos.clear()

	for i in range(max_concentracion):
		var ojo = TextureRect.new()
		ojo.texture = textura_ojo_abierto
		
		ojo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ojo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		ojo.custom_minimum_size = textura_ojo_abierto.get_size() * 0.075

		contenedor_concentracion.add_child(ojo)
		ojos.append(ojo)

func actualizar_concentracion(actual):
	for i in range(ojos.size()):
		if i < actual:
			ojos[i].texture = textura_ojo_abierto
		else:
			ojos[i].texture = textura_ojo_cerrado

func actualizar_cordura(actual):
	barra_cordura.value = actual
	label_cordura.text = "Cordura " + str(actual) + "%"
#==========================

# =========================
# ===== MENU CONTROL ======
# =========================

func abrir_menu(jugador):
	jugador_actual = jugador
	
	menu_izquierda.visible = true
	menu_derecha.visible = true
	panel_descripcion.visible = false

func cerrar_menu():
	menu_izquierda.visible = false
	menu_derecha.visible = false
	panel_descripcion.visible = false

func actualizar_turno(turno):
	label_turnos.text = "Turno: " + str(turno)

func actualizar_acciones(disponibles):
	label_acciones.text = "Acciones: " + str(disponibles)

# =========================
# ===== LIMPIAR LISTAS ====
# =========================

func limpiar_listas():
	for h in lista_habilidades.get_children():
		h.queue_free()
	for h in lista_arma.get_children():
		h.queue_free()

# =========================
# ===== CREAR BOTONES =====
# =========================

func agregar_habilidad(habilidad: Habilidad):
	var boton = Button.new()
	boton.text = habilidad.nombre

	boton.mouse_entered.connect(func():
		mostrar_info_habilidad(habilidad)
	)

	boton.pressed.connect(func():
		seleccionar_habilidad(habilidad)
	)

	lista_habilidades.add_child(boton)

func agregar_accion_arma(habilidad: Habilidad):
	var boton = Button.new()
	boton.text = habilidad.nombre

	boton.mouse_entered.connect(func():
		mostrar_info_habilidad(habilidad)
	)

	boton.pressed.connect(func():
		seleccionar_habilidad(habilidad)
	)

	lista_arma.add_child(boton)

# =========================
# ===== DESCRIPCION =======
# =========================

func mostrar_info_habilidad(habilidad: Habilidad):
	panel_descripcion.visible = true
	
	nombre.text = habilidad.nombre
	descripcion.text = habilidad.descripcion
	
	var texto_costo = ""
	
	if habilidad.costo_concentracion > 0:
		texto_costo += "Concentración: " + str(habilidad.costo_concentracion) + " "
	
	if habilidad.costo_cordura > 0:
		texto_costo += "Cordura: " + str(habilidad.costo_cordura)
	
	costo.text = texto_costo

# =========================
# ===== SELECCION =========
# =========================

func seleccionar_habilidad(habilidad: Habilidad):
	habilidad_seleccionada = habilidad
	
	cerrar_menu()
	
	Manager.establecer_personaje(jugador_actual)
	Manager.habilidad_actual = habilidad  
	Manager.mostrar_seleccion()
