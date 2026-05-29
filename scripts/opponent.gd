extends Resource
class_name Opponent

enum Type {
	WOLF,
	CROW,
	BOAR
}

@export var hp : int
@export var max_hp : int
@export var attack : int
@export var evasion : float
@export var blocks : int
@export var type : Type

var valid : bool = true

signal died(Opponent)

static var collection : Dictionary[Type, Opponent] = { 
	Type.WOLF: preload("res://resources/wolf.tres"),
	Type.CROW: preload("res://resources/crow.tres"),
	Type.BOAR: preload("res://resources/boar.tres"),
}
	
func execute():
	# TODO execute action
	pass

func get_damage(damage: int):
	hp -= damage
	
	if !hp:
		died.emit(self)

func get_heal(life: int):
	hp = min((hp + life), max_hp)
