extends Button
class_name OpponentVisual

@export var opponent: Opponent

signal clicked(OpponentVisual)

func _ready():
	pressed.connect(_selected)

func set_info(_opponent: Opponent):
	opponent = _opponent
	$Front/HP.text = str(opponent.hp)
	$Front/Damage.text = str(opponent.attack)
	$Front/Image.texture = opponent.picture

func _selected():
	clicked.emit(self)
