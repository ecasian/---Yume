extends Control

func elegir_posicion(pos):
	Manager.jugador.defendiendo = (pos == Personaje.Posicion.CENTRO)
	Manager.jugador.set_posicion(pos)
	Manager.emit_signal("defensa_elegida")

func _on_izquierda_pressed() -> void:
	elegir_posicion(Personaje.Posicion.IZQUIERDA)

func _on_defensa_pressed() -> void:
	elegir_posicion(Personaje.Posicion.CENTRO)

func _on_derecha_pressed() -> void:
	elegir_posicion(Personaje.Posicion.DERECHA)

func _on_abajo_pressed() -> void:
	elegir_posicion(Personaje.Posicion.AGACHADO)
