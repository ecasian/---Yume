extends Resource
class_name Habilidad

@export var nombre : String
@export var descripcion : String

# ===== COSTOS =====
@export var costo_concentracion : int = 0
@export var costo_cordura : float = 0.0
@export var turnos_bloqueo : int = 0

# ===== TIPO =====
@export var es_magica : bool = true
@export var es_cura : bool = false

# ===== DAÑO =====
@export var danio_base : float = 0.0
@export var multiplicador : float = 1.0

# ===== TARGETING =====
@export var es_aoe : bool = false
@export var cantidad_golpes : int = 1
@export var precision : float = 100.0
@export var porcentaje_de_critico: float = 0

# ===== POSICION =====
@export var posiciones_que_golpea : Array[int] = []
@export var ignora_posicion : bool = false

# ===== DIALOGOS =====
@export var ruta_dialogo: String
@export var id_dialogo: String

# =========================
# ===== VALIDACION ========
# =========================

func puede_usarse(stats) -> bool:
	if stats.obtener_concentracion_disponible() < costo_concentracion:
		return false
	
	if stats.Cordura_actual - costo_cordura < -100:
		return false
	
	return true

# =========================
# ===== COSTOS ============
# =========================

func aplicar_costos(stats):
	if costo_cordura > 0:
		stats.recibir_danio_cordura(costo_cordura)
	
	if costo_concentracion > 0:
		stats.bloquear_concentracion(costo_concentracion, turnos_bloqueo)

# =========================
# ===== CALCULO DAÑO ======
# =========================

func calcular_danio(usuario) -> float:
	var stat = 0
	
	if es_magica:
		stat = usuario.stats.Af_E
	else:
		stat = usuario.stats.Fuerza
	
	return danio_base + (multiplicador * stat)

func es_critico() -> bool:
	var roll = randf() * 100
	print("Crit roll:", roll, " / Prob:", porcentaje_de_critico)
	return roll <= porcentaje_de_critico

func aplicar_varianza(danio: float) -> float:
	var variacion = danio * 0.1
	return randf_range(danio - variacion, danio + variacion)

func aplicar_reduccion(objetivo, danio: float) -> float:
	var defensa = 0
	if es_magica:
		defensa = objetivo.stats.Res_E
	else:
		defensa = objetivo.stats.Res_F
	
	# cada punto = 0.5%
	var reduccion = defensa * 0.005
	#Aplica la reducción por defensa
	if objetivo.defendiendo:
		reduccion += 0.3
	
	# clamp para evitar negativos absurdos
	reduccion = clamp(reduccion, 0, 0.9)
	return danio * (1.0 - reduccion)

func calcular_danio_final(usuario, objetivo, esCritico) -> int:
	var base = calcular_danio(usuario)
	
	# ===== CRITICO =====
	if esCritico	:
		print("CRITICO!")
		return base * 2  # ignora todo
	
	# ===== VARIANZA =====
	var danio = aplicar_varianza(base)
	
	# ===== REDUCCION =====
	danio = aplicar_reduccion(objetivo, danio)
	
	return max(0, int(round(danio)))

# =========================
# ===== EJECUCION =========
# =========================

func ejecutar(usuario, objetivo, lista_enemigos = []):
	# aplicar costos
	aplicar_costos(usuario.stats)
	if !es_cura:
		# ===== AOE =====
		if es_aoe:
			for enemigo in lista_enemigos:
				aplicar_golpes(usuario, enemigo)
		
		# ===== SINGLE TARGET =====
		else:
			aplicar_golpes(usuario, objetivo)
	else:
		var cura = calcular_danio(usuario)
		usuario.stats.curar(cura)

# =========================
# ===== MULTIHIT ==========
# =========================

func aplicar_golpes(usuario, objetivo):
	if not ignora_posicion: 
		if objetivo.posicion_actual not in posiciones_que_golpea:
			print("Has esquivado el ataque")
			return
	
	for i in range(cantidad_golpes):
		if intentar_golpe(objetivo):
			var critico = es_critico()
			var danio_final = calcular_danio_final(usuario, objetivo, critico)
			objetivo.stats.recibir_danio(danio_final)
		else:
			print("Fallo el ataque")

# =========================
# ===== PRECISION ==========
# =========================
func calcular_probabilidad_acierto(objetivo) -> float:
	var evasion = objetivo.stats.Velocidad * 0.5
	return clamp(precision - evasion, 5, 100)

func intentar_golpe(objetivo) -> bool:
	var prob = calcular_probabilidad_acierto(objetivo)
	var roll = randf() * 100
	
	return roll <= prob
