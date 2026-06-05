extends Resource
class_name Effect

enum Type {Damage, Healing, Defense}

#@export var effect: Callable
@export var upgrade: Effect
@export var amount: int
@export var type: Type

func effect(caster: Player, target: Opponent):
	match type:
		Type.Damage:
			target.get_damage(amount)
		Type.Healing:
			caster.get_heal(amount)
		Type.Defense:
			caster.add_shield(amount)

#func effect(caster, target):
#	assert(false, "Effect.execute() must be implemented")
#	pass
