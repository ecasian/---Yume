extends Personaje
class_name Enemigo

@export var data : EnemigoData

var contador_ultimate : int = 0
var contador_habilidades := {} # Dialogos

func _ready():
	if data == null:
		push_error("Enemigo sin data")
		return
	if data.stats == null:
		push_error("EnemigoData sin stats")
		return
	super._ready()
	
	#inicializar(data.stats)
	#stats = data.stats.duplicate(true)
	#habilidades_arma = data.habilidades #Se usa el array de habilidades armas para todos los tipos de ataques del enemigo 
	#habilidades_magicas = data.ultimate #Para guardar la ultimate del enemigo2

func inicializar():
	if data == null:
		push_error("Enemigo sin data")
		return
	
	if data.stats == null:
		push_error("EnemigoData sin stats")
		return
		
	stats = data.stats.duplicate(true)
	
	habilidades_arma = data.habilidades
	habilidades_magicas = data.ultimate
	
	# Aqui ahora sí inicializamos como personaje
	stats.vida_cero.connect(_on_muerte)
	
	Manager.connect("jugador_selecciona_enemigo", mostrar_seleccion)
	Manager.connect("ataque_iniciado", ocultar_seleccion)
	if not Manager.enemigos.has(self):
		Manager.enemigos.append(self)
	
	calcular_acciones()
	acciones_actuales = acciones_max
	emit_signal("acciones_cambiadas", acciones_actuales)

func turno_enemigo() -> void:
	var habilidad
	if contador_ultimate == data.turnos_para_ultimate:
		habilidad = habilidades_magicas.pick_random()
		contador_ultimate = 0
	else:
		habilidad = elegir_habilidad()
		contador_ultimate += 1
	
	var objetivo = elegir_objetivo()
	
	Manager.habilidad_actual = habilidad
	Manager.establecer_personaje(self)
	Manager.establecer_objetivo(objetivo)
	var usos = registrar_uso_habilidad(habilidad)
	await Manager.iniciar_ataque(usos)

func elegir_objetivo():
	return Manager.jugador

"""
func elegir_habilidad():
	return habilidades_arma.pick_random()
"""

func elegir_habilidad():
	var opciones = []
	
	for h in habilidades_arma:
		var peso = evaluar_habilidad(h)
		opciones.append({ "habilidad": h, "peso": peso })
	
	return seleccionar_por_peso(opciones)

func evaluar_habilidad(habilidad):
	var peso = 1.0
	
	# Si hace mucho daño → más prioridad
	peso += habilidad.danio_base
	
	# Si el jugador tiene poca vida → agresivo
	if Manager.jugador.stats.Vida_actual < 30:
		peso += 5
	
	# Si no puede golpear por posición → inútil
	if not habilidad.ignora_posicion:
		if Manager.jugador.posicion_actual not in habilidad.posiciones_que_golpea:
			peso = 0
	
	return peso

func seleccionar_por_peso(opciones):
	var total = 0
	
	for o in opciones:
		total += o.peso
	
	if total == 0:
		return opciones.pick_random().habilidad # fallback
	
	var roll = randf() * total
	
	var acumulado = 0
	for o in opciones:    
		acumulado += o.peso
		if roll <= acumulado:
			return o.habilidad
	
	return opciones[0].habilidad

func registrar_uso_habilidad(habilidad: Habilidad) -> int:
	var key = habilidad.nombre
	
	if not contador_habilidades.has(key):
		contador_habilidades[key] = 0
	
	contador_habilidades[key] += 1
	
	return contador_habilidades[key]


func morir():
	Manager.remover_enemigo(self)
	queue_free()
