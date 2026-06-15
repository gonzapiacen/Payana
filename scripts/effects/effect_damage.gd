extends Effect
class_name Damage

func effect(_caster, target: Opponent):
	target.get_damage(amount)
