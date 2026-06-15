extends Button
class_name CardVisual

@export var card: Card

signal clicked(CardVisual)

func set_info(_card: Card):
	card = _card
	$Front/Cost.text = str(card.cost)
	$Front/Title.text = str(card.info.name)
	$Front/Image.texture = card.image
	pass

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)
