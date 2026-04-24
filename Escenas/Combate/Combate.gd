extends Node2D

@onready var jugador = $Jugador
@onready var ui = $UI

func _ready():
	Manager.inicializar_referencias(jugador, ui)
