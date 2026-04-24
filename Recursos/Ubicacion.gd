extends Resource
class_name Ubicacion

@export var nombre_lugar : StringName
@export var id : String
# ===== VISUAL =====
@export var fondo : Texture2D
# ===== DIALOGO =====
@export var ruta_dialogo : String
# ===== NAVEGACION =====
@export var conexiones := {
	"delante": "",
	"atras": "",
	"izquierda": "",
	"derecha": ""
}
# ===== COMBATE =====
@export var combate : CombatData
@export var combate_obligatorio : bool = false
# ===== NPC =====
#@export var npc_evento : EventoData
