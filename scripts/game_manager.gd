extends Node 
class_name GameManager

var card_stacks : CardStacks
var player : Player

func prepare_encounter(encounter: Encounter):
	for opp in encounter.opponent_list:
		var opp_instance = Opponent.collection[opp].new()
		card_stacks.opponent_slots.push_back(opp_instance)
		opp_instance.connect("died", verify_remains.bind(opp_instance))
	
	card_stacks.deck.shuffle()
	
func verify_remains(dead_opponent: Opponent):
	card_stacks.opponent_slots.erase(dead_opponent)
	if(!card_stacks.opponent_slots.size()):
		InputHandler.enable_only_map()
		select_next_node()
	
func start_player_turn():
	InputHandler.disable_all()
	
	await draw_cards()
	
	InputHandler.enable_player_action()

func play_card(index: int, target: int = 0):
	var card = card_stacks.player_hand[index]
	#var opponent = card_stacks.opponent_slots[target]
	if card.cost > player.energy:
		# TODO play feedback "not enough energy"
		print("I have no energy to do that...")
		return
	player.energy -= card.cost
	InputHandler.disable_all()
	# TODO distinguish between whether the target is the player or an opponent
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
			card_stacks.discard = []
			card_stacks.deck.shuffle()
		card_stacks.player_hand.push_back(card_stacks.deck.pop_back())
		if !card_stacks.deck:
			# TODO hide deck
			pass

func discard_card(index: int = 0):
	card_stacks.discard.push_back(card_stacks.player_hand.pop_at(index))

func finish_player_turn():
	InputHandler.disable_all()
	
	for i in range(0, player.hand_size):
		discard_card()
		
	start_opponent_turn()

func start_opponent_turn():
	for opponent in card_stacks.opponent_slots:
		# TODO opponent's actions
		opponent.execute()
		pass

	start_player_turn()

func select_next_node():
	# TODO show map and select node
	pass
