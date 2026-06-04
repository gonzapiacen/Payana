extends Resource
class_name Effect

#enum Type {Damage, Healing, Defense}

#@export var effect: Callable
@export var upgrade: Effect
@export var amount: int
#@export var type: Type

func effect(caster, target):
	assert(false, "Effect.execute() must be implemented")
	pass
