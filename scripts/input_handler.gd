extends Node
class_name InputHandler

signal hand_card_picked

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index



func pick_hand_card() -> Card:
	await hand_card_picked



