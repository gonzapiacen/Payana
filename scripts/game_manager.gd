extends Node 
class_name GameManager

var card_stacks : CardStacks
var player : Player

func prepare_encounter(encounter: Encounter):
	for opp in encounter.opponent_list:
		card_stacks.opponent_slots.push_back(Opponent.collection[opp].new())
	
	card_stacks.deck.shuffle()

func start_player_turn():
	InputHandler.disable_all()
	
	await draw_cards()
	
	InputHandler.enable_player_action()

#func play_card(index: int):
func play_card(index: int, target: int):
	var card = card_stacks.player_hand[index]
	if card.cost > player.energy:
		# TODO play feedback "not enough energy"
		return
	player.energy -= card.cost
	InputHandler.disable_all()
	for effect in card.effects:
		effect.effect.call()
		
	discard_card(index)
	InputHandler.enable_player_action()
	
func draw_cards():
	for i in range(0, player.hand_size):
		if card_stacks.deck.is_empty():
			if card_stacks.discard.is_empty():
				break
			card_stacks.deck = card_stacks.discard
			card_stacks.deck.shuffle()
		card_stacks.player_hand.push_back(card_stacks.deck.pop_back())

func discard_card(index: int):
	card_stacks.discard.push_back(card_stacks.player_hand.pop_at(index))

func finish_player_turn():
	InputHandler.disable_all()
	
	for i in range(0, player.hand_size):
		discard_card(i)
		
	start_opponent_turn()

func start_opponent_turn():
	for opponent in card_stacks.opponent_slots:
		#REALIZAR ACCIÓN DE OPONENTE
		pass

	start_player_turn()
