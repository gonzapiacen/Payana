extends Node
class_name UIManager

var visual_card_scene = preload("res://scenes/card_visual.tscn")
var visual_opponent_scene = preload("res://scenes/opponent_visual.tscn")

@onready var pass_turn_button = $PassButton

signal target_selected(Variant)
#signal change_turn

#var tween : Tween

func _ready():
	await GameManager.init_logic()
	
	GameManager.create_card.connect(_create_card)
	GameManager.move_card_deck_to_hand.connect(_move_card_deck_to_hand)
	GameManager.move_card_hand_to_discard.connect(_move_card_hand_to_discard)
	#GameManager.move_card_hand_to_field.connect(_move_card_hand_to_field)
	GameManager.opponent_in_field.connect(_put_opponent_in_field)
	GameManager.no_energy.connect(_show_alert)
	GameManager.update_energy.connect(_update_energy_player)
	GameManager.player.update_protection.connect(_update_shield_player)
	GameManager.delete_enemy.connect(_delete_enemy)
	GameManager.is_player_turn.connect(_enable_player_options)
	GameManager.put_discard_in_deck.connect(_put_discard_in_deck)
	
	pass_turn_button.pressed.connect(_change_turn)
	
	GameManager.init_game()
	
func _create_card(_card_info: Card):
	var visual_card_instance = visual_card_scene.instantiate()
	visual_card_instance.set_info(_card_info)
	set_size_deck($Deck/Label.text.to_int()+1)
	$Deck/Cards.add_child(visual_card_instance)
	visual_card_instance.clicked.connect(_selected_card)

func set_size_deck(amount: int):
	$Deck/Label.text = str(amount)

func _move_card_deck_to_hand(_card: Card, new_size_deck: int):
	var tween = create_tween()
	
	var card_to_move
	for instance_card in $Deck/Cards.get_children():
		if(instance_card.card == _card):
			card_to_move = instance_card
			break
	#if(!card_to_move):
		#print("Card doesn't exist in deck")
		#return
	for slot in $Hand.get_children():
		if(!slot.get_children()):
			$Deck/Label.text = str(new_size_deck)
			if(!new_size_deck):
				$Deck.visible = false
				
			card_to_move.reparent(slot)
			tween.tween_property(card_to_move,"position",Vector2(0,0),.25)
			#card_to_move.position = Vector2(0,0)
			tween.tween_property(card_to_move.get_node("Back"),"scale",Vector2(0,1),.125)
			tween.tween_property(card_to_move.get_node("Front"),"scale",Vector2(1,1),.125)
			#card_to_move.get_node("Back").visible = false
			await tween.finished
			break

func _update_shield_player(amount: int):
	for i in range(amount):
		$Status/Shields.get_children()[i].visible = true
		
func _show_alert(alert_desc: String):
	var tween = create_tween()
	$Alert.text = alert_desc
	tween.tween_property($Alert,"modulate:a",1,1)
	tween.tween_property($Alert,"modulate:a",0,2)
	await tween.finished

func _update_energy_player(player: Player):
	for i in range(player.energy):
		$Status/EnergyBar.get_children()[i].visible = true
		
	for i in range(player.max_energy-1,player.energy-1,-1):
		$Status/EnergyBar.get_children()[i].visible = false

func _move_card_hand_to_discard(_card: Card):
	var tween = create_tween()
	
	var card_to_move
	var initial_position
	var final_position = $Discard/Cards.global_position
	
	for slot_card in $Hand.get_children():
		if(slot_card.get_child(0) and slot_card.get_child(0).card == _card):
			
			card_to_move = slot_card.get_child(0)
			break
			
	if(!card_to_move):
		print("Card doesn't exist in discard")
		return
	
	initial_position = card_to_move.global_position
	card_to_move.reparent($".")
	card_to_move.global_position = initial_position
	tween.tween_property(card_to_move,"global_position",final_position,.25)
	await tween.finished
	card_to_move.reparent($"Discard/Cards")

func _move_card_hand_to_field(_card: Card, _pos: int):
	var card_to_move
	for instance_card in $Deck/Hand:
		if(instance_card.card == _card):
			card_to_move = instance_card
			break
	if(!card_to_move):
		print("Card doesn't exist on field")
		return
	if($PlayerField.get_children()[_pos].get_child_count()):
		print("Slot is busy")
		return
	
	card_to_move.reparent($PlayerField.get_children()[_pos])

func _put_opponent_in_field(opp_to_put: Opponent):
	
	var tween = create_tween()
	
	var visual_opponent_instance = visual_opponent_scene.instantiate()
	visual_opponent_instance.set_info(opp_to_put)
	$".".add_child(visual_opponent_instance)
	visual_opponent_instance.global_position = Vector2($".".size.x/2,-1 * visual_opponent_instance.size.y)
	var slot_to_put_opponent
	for slot in $OpponentField.get_children():
		if(!slot.get_child_count()):
			slot_to_put_opponent = slot
			break
			
	tween.tween_property(visual_opponent_instance,"global_position",slot_to_put_opponent.global_position,.2)
	await tween.finished
	visual_opponent_instance.reparent(slot_to_put_opponent)
	
	opp_to_put.update_life.connect(_update_life_opponent)
	visual_opponent_instance.clicked.connect(_on_target_selected)

func _selected_card(instantiated_card: CardVisual):
	
	for slot in $Hand.get_children():
		#if($Hand.get_children()[slot].get_child(0) && $Hand.get_children()[slot].get_child(0) == instantiated_card):
		if(slot.get_child(0) && slot.get_child(0) == instantiated_card):
			if(!GameManager.enough_energy(instantiated_card.card)):
				break
			if(GameManager.needs_a_target(instantiated_card.card)):
				instantiated_card.clicked.disconnect(_selected_card)
				instantiated_card.clicked.connect(_on_target_selected)
				var target = await select_target(instantiated_card)
				if(target == instantiated_card):
					print("Cancel card to play")
					instantiated_card.clicked.connect(_selected_card)
					instantiated_card.clicked.disconnect(_on_target_selected)
					for hand_slot in $Hand.get_children():
						var card_in_hand = hand_slot.get_child(0)
						if(card_in_hand):
							card_in_hand.modulate.a = 1
							card_in_hand.clicked.connect(_selected_card)
					pass_turn_button.disabled = false
				else:
					for hand_slot in $Hand.get_children():
						var card_in_hand = hand_slot.get_child(0)
						if(card_in_hand):
							card_in_hand.modulate.a = 1
							card_in_hand.clicked.connect(_selected_card)
					GameManager.play_card(instantiated_card.card,target.opponent)
					pass_turn_button.disabled = false
				break
			else:
				#GameManager.play_card(slot - no_cards)
				GameManager.play_card(instantiated_card.card)
			break
		#else:
			#no_cards += 1

func _update_life_opponent(opp_to_update: Opponent):
	var visual_opp_to_update
	for opp in $OpponentField.get_children():
		if(opp.get_child(0) && opp.get_child(0).opponent == opp_to_update):
			visual_opp_to_update = opp.get_child(0)
			break
	visual_opp_to_update.get_node("Front/HP").text = str(opp_to_update.hp)

func _delete_enemy(opp_to_delete: Opponent):
	var visual_opp_to_delete
	for opp in $OpponentField.get_children():
		if(opp.get_child(0) && opp.get_child(0).opponent == opp_to_delete):
			visual_opp_to_delete = opp.get_child(0)
			break
	visual_opp_to_delete.queue_free()

func _change_turn():
	pass_turn_button.disabled = true
	GameManager.finish_player_turn()

func _enable_player_options():
	$PassButton.disabled = false
	_update_energy_player(GameManager.player)

func _put_discard_in_deck(_card: Card):
	var tween = create_tween()
	$Deck.visible = true
	var visual_card_to_move
	for visual_card in $Discard/Cards.get_children():
		if (visual_card.card == _card):
			visual_card_to_move = visual_card
			break
	
	if(!visual_card_to_move):
		print(_card, " doesn't exist")
		return
		
	tween.set_parallel(true)
	tween.tween_property(visual_card_to_move,"global_position",$Deck/Cards.global_position,.25)
	tween.tween_property(visual_card_to_move.get_node("Front"),"scale",Vector2(0,1),.25)
	tween.tween_property(visual_card_to_move.get_node("Back"),"scale",Vector2(1,1),.25)
	tween.set_parallel(false)
	
	await tween.finished
	#visual_card_to_move.get_node("Front").scale = Vector2(0,1)
	#visual_card_to_move.get_node("Back").scale = Vector2(1,1)
	visual_card_to_move.reparent($Deck/Cards)
	set_size_deck($Deck/Cards.get_child_count())
		
#func _on_target_selected(opp_visual: OpponentVisual):
	#target_selected.emit(opp_visual)
	
func _on_target_selected(card_visual: Variant):
	target_selected.emit(card_visual)
	
func select_target(card_to_play: CardVisual) -> Variant:
	card_to_play.scale = Vector2(1.2,1.2)
	for slot in $OpponentField.get_children():
		var opponent_to_select = slot.get_child(0)
		if(opponent_to_select):
			opponent_to_select.scale = Vector2(1.2,1.2)
			
	for slot in $Hand.get_children():
		var card_in_hand = slot.get_child(0)
		if(card_in_hand && card_in_hand != card_to_play):
			print("deshabilitando carta en mano")
			card_in_hand.modulate.a = 0.2
			card_in_hand.clicked.disconnect(_selected_card)
			
	pass_turn_button.disabled = true
			
	print("Select the target...")
	var selected = await target_selected
	
	#for pos in $OpponentField.get_children().size():
	for opp in $OpponentField.get_children():
		var opponent_to_select = opp.get_child(0)
		if(opponent_to_select):
			opponent_to_select.scale = Vector2(1,1)
	
	if(selected == card_to_play):
		card_to_play.scale = Vector2.ONE
		return card_to_play
	
	return selected
