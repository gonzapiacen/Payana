extends Resource
class_name Opponent

enum Type {
	WOLF,
	CROW,
	BOAR
}

@export var picture: CompressedTexture2D
@export var hp : int
@export var max_hp : int
@export var attack : int
@export var evasion : float
@export var blocks : int
@export var type : Type

var valid : bool = true

signal died(Opponent)
signal update_life(Opponent)

static var collection : Dictionary[Type, Opponent] = { 
	Type.WOLF: load("res://resources/opponents/wolf.tres"),
	Type.CROW: load("res://resources/opponents/crow.tres"),
	Type.BOAR: load("res://resources/opponents/boar.tres"),
}
	
func execute():
	# TODO execute action
	pass

func get_damage(damage: int):
	hp -= damage
	if !hp:
		died.emit(self)
	else:
		update_life.emit(self)

func get_heal(life: int):
	hp = min((hp + life), max_hp)
