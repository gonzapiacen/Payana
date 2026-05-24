extends Node 
class_name GameManager

var card_stacks : CardStacks
var player : Player

func prepare_encounter(encounter: Encounter):
	for opp in encounter.opponent_list:
		card_stacks.opponent_slots.push_back(Opponent.collection[opp].new())
	
	card_stacks.deck.shuffle()

func start_player_turn():
	for i in range(0, player.hand_size):
		if card_stacks.deck.is_empty():
			if card_stacks.discard.is_empty():
				break
			card_stacks.deck = card_stacks.discard
			card_stacks.deck.shuffle()
		card_stacks.player_hand.push_back(card_stacks.deck.pop_back())
	
	InputHandler.enable_player_action()

func play_card(index: int):
	var card = card_stacks.player_hand[index]
	if card.cost > player.energy:
		# TODO play feedback "not enough energy"
		return
	player.energy -= card.cost
	InputHandler.disable_all()
	for effect in card.effects:
		effect.effect.call()
	InputHandler.enable_player_action()

