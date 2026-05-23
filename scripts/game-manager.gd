extends Node 
class_name GameManager

var card_stacks : CardStacks
var player : Player

func prepare_encounter(encounter: Encounter):
	for opp in encounter.opponent_list:
		card_stacks.opponent_slots.push_back(Opponent.collection[opp].new())
	
	card_stacks.deck.shuffle()

func player_turn():
	for i in range(0, player.hand_size):
		if card_stacks.deck.is_empty():
			if card_stacks.discard.is_empty():
				break
			card_stacks.deck = card_stacks.discard
			card_stacks.deck.shuffle()
		card_stacks.player_hand.push_back(card_stacks.deck.pop_back())
	
	# el jugador tiene la oportunidad de elegir carta
	var picked_card := 
	


