extends Resource
class_name Medicamentos

@export var stat : StringName
@export var valor : float
@export var fuente : StringName
@export var tipo : StringName
@export var afecta_vida : bool
@export var afecta_cordura : bool

func usar(objetivo):
	if afecta_vida:
		objetivo.stats.curar(valor)
		return
	
	if afecta_cordura:
		objetivo.stats.curar_cordura(valor)
		return
	
	var mod = Stat_mod.new()
	
	mod.stat = stat
	mod.valor = valor
	mod.fuente = fuente
	mod.tipo = tipo
	
	objetivo.stats.añadir_modificador(mod)
