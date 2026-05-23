extends Resource
class_name Card

enum Type{Instant, Permanent}
@export var cost: int
@export var effects: Array[Effect]
@export var type: Type
