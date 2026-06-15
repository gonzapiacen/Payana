extends Node

signal create_card(Card)

signal move_card_deck_to_hand(Card, int)
#signal move_card_hand_to_field(Card)
signal move_card_hand_to_discard(Card)

signal opponent_in_field(Opponent,int)

signal update_energy(Player)

var card_stacks : CardStacks
var player : Player

func _ready():
	player = Player.new()
	await get_tree().process_frame
	await prepare_encounter(load("res://resources/encounters/01.tres"))
	print("Let's start the party")
	start_player_turn()

func prepare_encounter(encounter: Encounter):
	
	card_stacks = CardStacks.new()
	
	player.hand_size = 3
	player.max_energy = 3
	player.energy = 3
	
	for opp in encounter.opponent_list:
		var opp_instance = Opponent.collection[opp].duplicate()
		await get_tree().create_timer(1.0).timeout
		opponent_in_field.emit(opp_instance,card_stacks.opponent_slots.size())
		opp_instance.connect("died", verify_remains.bind(opp_instance))
		card_stacks.opponent_slots.push_back(opp_instance)
		
	for i in range(3):
		var new_card_to_deck = Card.new()
		new_card_to_deck.set_info(load("res://resources/cards/poncho.tres"))
		card_stacks.deck.push_back(new_card_to_deck)
		create_card.emit(new_card_to_deck)
		await get_tree().create_timer(.025).timeout
		new_card_to_deck = Card.new()
		new_card_to_deck.set_info(load("res://resources/cards/facon.tres"))
		card_stacks.deck.push_back(new_card_to_deck)
		create_card.emit(new_card_to_deck)
	
	card_stacks.deck.shuffle()
	
func verify_remains(dead_opponent: Opponent):
	card_stacks.opponent_slots.erase(dead_opponent)
	if(!card_stacks.opponent_slots.size()):
		InputHandler.enable_only_map()
	
func start_player_turn():
	InputHandler.disable_all()
	print("Por robar")
	draw_cards()
	
	InputHandler.enable_player_action()

func play_card(index: int, target: int = 0):
	var card = card_stacks.player_hand[index]
	#var opponent = card_stacks.opponent_slots[target]
	if card.cost > player.energy:
		# TODO play feedback "not enough energy"
		print("I have no energy to do that...")
		return
	player.energy -= card.cost
	update_energy.emit(player)
	InputHandler.disable_all()
	# TODO distinguish between whether the target is the player or an opponent
	for effect in card.effects:
		#effect.effect.call()
		effect.effect(player,card_stacks.opponent_slots[target])
		pass
	discard_card(index)
	
	InputHandler.enable_player_action()

func draw_cards():
	for i in range(0, player.hand_size):
		if card_stacks.deck.is_empty():
			print("empty deck")
			if card_stacks.discard.is_empty():
				print("empty discard")
				break
			card_stacks.deck = card_stacks.discard
			card_stacks.discard = []
			card_stacks.deck.shuffle()
		await get_tree().create_timer(1.0).timeout
		var card_to_hand = card_stacks.deck.pop_back()
		#create_card.emit(card_to_hand)
		card_stacks.player_hand.push_back(card_to_hand)
		move_card_deck_to_hand.emit(card_to_hand, card_stacks.deck.size())

func discard_card(index: int = 0):
	var card_to_discard = card_stacks.player_hand.pop_at(index)
	card_stacks.discard.push_back(card_to_discard)
	move_card_hand_to_discard.emit(card_to_discard)

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
