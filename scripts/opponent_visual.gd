extends Button
class_name OpponentVisual

@export var opponent: Opponent

signal clicked(Opponent)

func set_info(_opponent: Opponent):
	opponent = _opponent
	$Front/HP.text = str(opponent.hp)
	$Front/Damage.text = str(opponent.attack)
	$Front/Image.texture = opponent.picture

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
