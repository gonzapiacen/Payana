extends Resource
class_name Effect

enum Type {Damage, Healing, Defense}

@export var effect: Callable
@export var upgrade: Effect
@export var type: Type
