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

