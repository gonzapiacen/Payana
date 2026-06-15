extends Node
class_name UIManager

var visual_card_scene = preload("res://scenes/card_visual.tscn")
var visual_opponent_scene = preload("res://scenes/opponent_visual.tscn")

signal selected_card(Card)

func _ready():
	GameManager.create_card.connect(_create_card)
	GameManager.move_card_deck_to_hand.connect(_move_card_deck_to_hand)
	GameManager.move_card_hand_to_discard.connect(_move_card_hand_to_discard)
	#GameManager.move_card_hand_to_field.connect(_move_card_hand_to_field)
	
	GameManager.opponent_in_field.connect(_put_opponent_in_field)
	GameManager.update_energy.connect(_update_energy_player)
	GameManager.player.update_protection.connect(_update_shield_player)

func _create_card(_card_info: Card):
	var visual_card_instance = visual_card_scene.instantiate()
	visual_card_instance.set_info(_card_info)
	$Deck/Label.text = str($Deck/Label.text.to_int()+1)
	$Deck/Cards.add_child(visual_card_instance)
	visual_card_instance.clicked.connect(_selected_card)

func set_size_deck(amount: int):
	$Deck.text = str(amount)

func _move_card_deck_to_hand(_card: Card, new_size_deck: int):
	var card_to_move
	for instance_card in $Deck/Cards.get_children():
		if(instance_card.card == _card):
			card_to_move = instance_card
			break
	if(!card_to_move):
		print("Card doesn't exist")
		return
	for slot in $Hand.get_children():
		if(!slot.get_children()):
			card_to_move.reparent(slot)
			card_to_move.position = Vector2(0,0)
			card_to_move.get_node("Back").visible = false
			$Deck/Label.text = str(new_size_deck)
			if(!new_size_deck):
				$Deck.visible = false
			break

func _update_shield_player(amount: int):
	print("escudando")
	for i in range(amount):
		$Status/Shields.get_children()[i].visible = true
	pass

func _update_energy_player(player: Player):
	for i in range(player.max_energy-1,player.energy-1,-1):
		$Status/EnergyBar.get_children()[i].visible = false

func _move_card_hand_to_discard(_card: Card):
	var card_to_move
	for instance_card in range($Hand.get_children().size()):
		if($Hand.get_children()[instance_card].get_child(0).card == _card):
			card_to_move = $Hand.get_children()[instance_card].get_child(0)
			selected_card.emit(instance_card)
			$Hand.get_children()[instance_card].visible = false
			break
	if(!card_to_move):
		print("Card doesn't exist")
		return
	
	card_to_move.reparent($Discard/Cards)

func _move_card_hand_to_field(_card: Card, _pos: int):
	var card_to_move
	for instance_card in $Deck/Hand:
		if(instance_card.card == _card):
			card_to_move = instance_card
			break
	if(!card_to_move):
		print("Card doesn't exist")
		return
	if($PlayerField.get_children()[_pos].get_child_count()):
		print("Slot is busy")
		return
	
	card_to_move.reparent($PlayerField.get_children()[_pos])

func _put_opponent_in_field(opp_to_put: Opponent, slot: int):
	var visual_opponent_instance = visual_opponent_scene.instantiate()
	visual_opponent_instance.set_info(opp_to_put)
	$OpponentField.get_child(slot).add_child(visual_opponent_instance)
	opp_to_put.update_life.connect(_update_life_opponent)
	pass

func _selected_card(instantiated_card: CardVisual):
	#TODO select target
	var no_cards: int = 0
	for slot in range($Hand.get_children().size()):
		if($Hand.get_children()[slot].get_child(0)):
			if($Hand.get_children()[slot].get_child(0) == instantiated_card):
				GameManager.play_card(slot - no_cards)
				break
		else:
			no_cards += 1

func _update_life_opponent(opp_to_update: Opponent):
	var visual_opp_to_update
	for opp in $OpponentField.get_children():
		if(opp.get_child(0) && opp.get_child(0).opponent == opp_to_update):
			visual_opp_to_update = opp.get_child(0)
			break
	print(visual_opp_to_update)
	visual_opp_to_update.get_node("Front/HP").text = str(opp_to_update.hp)
