extends Resource
class_name CombatData

@export var spawns: Array[EnemySpawnData]

@export var fondo: Texture2D
@export var musica: AudioStream

# opcional (futuro)
@export var es_boss: bool = false
@export var recompensa: Resource
@export var nombre_combate: String = ""
@export var descripcion: String = ""
