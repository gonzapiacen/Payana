extends RefCounted
class_name Player

var hp : int
var max_hp : int
var energy : int
var max_energy : int
var blocks : int
var hand_size : int

signal died(Player)
signal update_protection(int)

func add_protection(amount: int):
	blocks = min(blocks + amount, 3)
	update_protection.emit(blocks)

func get_damage(damage: int):
	hp -= damage
	
	if !hp:
		died.emit(self)

func get_heal(life: int):
	hp = min((hp + life), max_hp)

func add_shield(shield: int):
	blocks += shield
