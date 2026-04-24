extends Control

@onready var btn_arriba = $CenterContainer/GridContainer/Arriba
@onready var btn_abajo = $CenterContainer/GridContainer/Abajo
@onready var btn_izquierda = $CenterContainer/GridContainer/Izquierda
@onready var btn_derecha = $CenterContainer/GridContainer/Derecha

func _ready():
	btn_arriba.pressed.connect(_on_arriba_pressed)
	btn_abajo.pressed.connect(_on_abajo_pressed)
	btn_izquierda.pressed.connect(_on_izquierda_pressed)
	btn_derecha.pressed.connect(_on_derecha_pressed)

func actualizar_flechas(ubicacion):
	btn_arriba.visible = ubicacion.conexiones["delante"] != ""
	btn_abajo.visible = ubicacion.conexiones["atras"] != ""
	btn_izquierda.visible = ubicacion.conexiones["izquierda"] != ""
	btn_derecha.visible = ubicacion.conexiones["derecha"] != ""

func _on_abajo_pressed():
	if GameManager.estado_actual == GameManager.EstadoJuego.EXPLORACION:
		GameManager.mover("atras")

func _on_arriba_pressed():
	if GameManager.estado_actual == GameManager.EstadoJuego.EXPLORACION:
		GameManager.mover("delante")

func _on_derecha_pressed():
	if GameManager.estado_actual == GameManager.EstadoJuego.EXPLORACION:
		GameManager.mover("derecha")

func _on_izquierda_pressed() -> void:
	if GameManager.estado_actual == GameManager.EstadoJuego.EXPLORACION:
		GameManager.mover("izquierda")
