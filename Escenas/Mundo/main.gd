extends Node2D

@onready var ui = $MainUI
@onready var jugador = $Jugador

func _ready():
	GameManager.inicializar(jugador, ui)
