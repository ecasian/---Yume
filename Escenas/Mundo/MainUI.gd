extends Node

@onready var fondo = $"../Fondo/Margen Pantalla/Fondo"
@onready var dialogue = $"../Dialogue"

func cambiar_fondo(texture):
	fondo.texture = texture

func mostrar_dialogo(ruta: String):
	var recurso = load(ruta)
	
	dialogue.start(recurso)
	dialogue.visible = true
	
	await dialogue.finished
	
	dialogue.visible = false

func modo_combate(valor: bool):
	pass
