extends Resource
class_name Escenario

@export var ubicacion_inicial : String
@export var lista_ubicaciones : Array[Ubicacion]

var ubicaciones := {}

func construir_diccionario():
	for u in lista_ubicaciones:
		ubicaciones[u.id] = u
