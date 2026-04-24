extends Node
class_name Inventario

class Espacio_objeto:
	var obj : Datos_Objetos
	var cantidad : int

signal Actualizar_inventario
signal Actualizar_espacio_inv (espacio_inv : Espacio_objeto)

var espacios_de_objetos : Array[Espacio_objeto]

@export var tamaño : int = 12
@export var Objetos_iniciales : Dictionary[Datos_Objetos, int]

func _ready():
	#--- Aquí se crea el tamaño del inventario, los "espacios" ---
	for i in range(tamaño):
		espacios_de_objetos.append(Espacio_objeto.new())
	
	#--- Aquí se inicializan los objetos iniciales en el inventario ---
	for key in Objetos_iniciales:
		for i in range(Objetos_iniciales[key]):
			añadir_objeto(key)

#------Añade objeto al inventario-----------------------------------------------
func añadir_objeto (obj : Datos_Objetos) -> bool:
	var espacio : Espacio_objeto = retorna_espacio_obj(obj)
	
	if espacio and espacio.cantidad < obj.stack_maximo:
		espacio.cantidad += 1
	else:
		espacio = retorna_espacio_obj_vacio()
		if not espacio:
			return false
		espacio.obj = obj
		espacio.cantidad = 1
	
	Actualizar_inventario.emit()
	Actualizar_espacio_inv.emit(espacio)
	return true

#------Remueve objeto del inventario--------------------------------------------
func remover_objeto (obj : Datos_Objetos):
	if not buscar_objeto(obj):
		return
	
	var espacio : Espacio_objeto = retorna_espacio_obj(obj)
	remover_objeto_de_espacio(espacio)

#------Remueve objeto de espacio especifico del inventario----------------------
func remover_objeto_de_espacio (espacio : Espacio_objeto):
	if not espacio.obj:
		return
	
	if espacio.cantidad == 1:
		espacio.obj = null
	else:
		espacio.cantidad -= 1
	
	Actualizar_inventario.emit()
	Actualizar_espacio_inv.emit(espacio)

#------Retorna el espacio del inventario que contiene el objeto especifico------
func retorna_espacio_obj (obj : Datos_Objetos) -> Espacio_objeto:
	for espacio in espacios_de_objetos:
		if espacio.obj == obj:
			return espacio
	
	return null

#------Retorna el espacio del inventario sin objetos en el----------------------
func retorna_espacio_obj_vacio () -> Espacio_objeto:
	for espacio in espacios_de_objetos:
		if espacio.obj == null: 
			return espacio
	
	return null

#------Revisa si el objeto esta en el inventario--------------------------------
func buscar_objeto (obj : Datos_Objetos) -> bool:
	for espacio in espacios_de_objetos:
		if espacio.obj == obj:
			return true
	
	return false
