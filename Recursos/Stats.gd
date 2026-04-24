extends Resource
class_name Stats

signal vida_cero()
signal vida_cambiada(valor_actual, valor_maximo)
signal cordura_cambiada(actual, maximo)

# ===== CONCENTRACION =====
signal concentracion_cambiada(actual, maximo)
# =========================

@export var jugador : bool
@export var Vida_maxima : float = 100.0
@export var Vida_actual : float = 100.0
@export var Cordura_maxima : float = 100.0
@export var Cordura_actual : float = 100.0

# ===== CONCENTRACION =====
@export var Concentracion_maxima : int = 1
var bloqueos_concentracion : Array = []
# =========================

@export var Fuerza : int = 10
@export var Af_E : int = 10 # Afinidad Esoterica == Magia
@export var Res_F : int = 10 # Resistencia fisica
@export var Res_E : int = 10 # Resistencia Esoterica
@export var Velocidad : int = 10
@export var Iluminacion : int = 1

# ---- Mejorar o bajar stats --------------------------------------------------
var modificadores : Array[Stat_mod] = []

func obtener_estadisticas(stat_nombre: StringName) -> float:
	var stat_base = get(stat_nombre)
	var total_bonus := 0.0
	
	for mod in modificadores:
		if mod.stat == stat_nombre:
			total_bonus += mod.valor
	return stat_base + total_bonus

func añadir_modificador(mod: Stat_mod):
	modificadores.append(mod)

func remover_modificador_fuente(fuente: StringName):
	modificadores = modificadores.filter(func(mod): return mod.fuente != fuente)

func remover_modificador_tipo(tipo: StringName):
	modificadores = modificadores.filter(func(mod): return mod.tipo != tipo)

# ---- Funciones para aplicar daño o curar la vida actual ---------------------
func recibir_danio(danio: float) -> void:
	Vida_actual -= danio
	Vida_actual = clamp(Vida_actual, 0.0, Vida_maxima)
	print("Daño recibido: ", danio)
	emit_signal("vida_cambiada", Vida_actual, Vida_maxima)
	
	if (Vida_actual <= 0):
		emit_signal("vida_cero")

func curar(cura: float) -> void:
	Vida_actual += cura
	Vida_actual = clamp(Vida_actual, 0.0, obtener_estadisticas(&"Vida_maxima"))
	emit_signal("vida_cambiada", Vida_actual, Vida_maxima)

# ---- Funciones para aplicar daño o curar la cordura actual ---------------------
func recibir_danio_cordura(danio: float) -> void:
	Cordura_actual -= danio
	Cordura_actual = clamp(Cordura_actual, -100.0, Cordura_maxima)
	emit_signal("cordura_cambiada", Cordura_actual, Cordura_maxima)

func curar_cordura(cura: float) -> void:
	Cordura_actual += cura
	Cordura_actual = clamp(Cordura_actual, -100.0, Cordura_maxima)
	emit_signal("cordura_cambiada", Cordura_actual, Cordura_maxima)

# ===== CONCENTRACION =====

# Obtener concentración disponible real
func obtener_concentracion_disponible() -> int:
	var bloqueado := 0
	
	for b in bloqueos_concentracion:
		bloqueado += b.cantidad
	
	return max(0, Concentracion_maxima - bloqueado)

# Aplicar bloqueo (habilidades)
func bloquear_concentracion(cantidad: int, turnos: int):
	bloqueos_concentracion.append({
		"cantidad": cantidad,
		"turnos": turnos
	})
	
	emitir_concentracion()

# Reducir turnos (llamar cada turno)
func actualizar_bloqueos():
	for b in bloqueos_concentracion:
		b.turnos -= 1
	
	# eliminar los que ya terminaron
	bloqueos_concentracion = bloqueos_concentracion.filter(func(b):
		return b.turnos > 0
	)
	
	emitir_concentracion()

# Emitir señal para UI
func emitir_concentracion():
	var actual = obtener_concentracion_disponible()
	emit_signal("concentracion_cambiada", actual, Concentracion_maxima)

# =========================
