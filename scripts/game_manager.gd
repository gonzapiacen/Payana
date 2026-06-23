extends Node

signal create_card(Card)

signal move_card_deck_to_hand(Card, int)
signal move_card_hand_to_discard(Card)

signal opponent_in_field(Opponent,int)

signal no_energy
signal update_energy(Player)

signal delete_enemy(Opponent)

signal is_player_turn

signal put_discard_in_deck

var card_stacks : CardStacks
var player : Player

var player_turn: bool

var encounter = load("res://resources/encounters/01.tres")

var poncho = preload("res://resources/cards/poncho.tres")
var facon = preload("res://resources/cards/facon.tres")
var fierro = preload("res://resources/cards/fierro.tres")

func init_logic():
	player = Player.new()
	player.hand_size = 3
	player.max_energy = 3
	player.energy = 3

func init_game():
	#await get_tree().process_frame
	await prepare_encounter()
	print("Let's start the party")
	player_turn = true
	start_player_turn()
	
func prepare_encounter():
	
	card_stacks = CardStacks.new()
	
	for i in encounter.opponent_list:
		await put_opponent_in_field(i)
		await get_tree().create_timer(.5).timeout
		
	for i in range(3):
		await put_card_in_deck(poncho)
		await get_tree().create_timer(.1).timeout
			
	for i in range(3):
		await put_card_in_deck(facon)
		await get_tree().create_timer(.1).timeout
			
	for i in range(3):
		await put_card_in_deck(fierro)
		await get_tree().create_timer(.1).timeout
				
	card_stacks.deck.shuffle()
	
func put_opponent_in_field(opp: int):
	var opp_instance = Opponent.collection[opp].duplicate()
	card_stacks.opponent_slots.push_back(opp_instance)
	opp_instance.died.connect(verify_remains)
	opponent_in_field.emit(opp_instance)
	
func put_card_in_deck(_res: Resource):
	var new_card_to_deck = Card.new()
	new_card_to_deck.set_info(_res)
	card_stacks.deck.push_back(new_card_to_deck)
	create_card.emit(new_card_to_deck)
	
func verify_remains(dead_opponent: Opponent):
	card_stacks.opponent_slots.erase(dead_opponent)
	delete_enemy.emit(dead_opponent)
	if(!card_stacks.opponent_slots.size()):
		print("YOU ARE TREMENDO: GANASTE :D")
		#InputHandler.enable_only_map()
		get_tree().quit()
	
func start_player_turn():
	InputHandler.disable_all()
	player.energy = player.max_energy
	is_player_turn.emit()
	for i in range(player.hand_size):
		await draw_card()
		await get_tree().create_timer(.5).timeout
		
	InputHandler.enable_player_action()
	
func enough_energy(card:Card) -> bool:
	var can_play = card.cost <= player.energy
	if(!can_play):
		no_energy.emit("I have no energy to do that")
		#print("I have no energy to do that...")
	
	return can_play

#func play_card(index: int, target: int = 0):
func play_card(card_to_play: Card, target: Opponent = null):
	#var card = card_stacks.player_hand[index]
	#var opponent = card_stacks.opponent_slots[target]
	#if card.cost > player.energy:
	#	# TODO play feedback "not enough energy"
	#	print("I have no energy to do that...")
	#	return
	player.energy -= card_to_play.cost
	update_energy.emit(player)
	InputHandler.disable_all()
	# TODO distinguish between whether the target is the player or an opponent
	for effect in card_to_play.effects:
		#effect.effect.call()
		#effect.effect(player,card_stacks.opponent_slots[target])
		effect.effect(player,target)
	await discard_card(card_to_play)
	
	InputHandler.enable_player_action()
	
func replenish(_card: Card):
	
	card_stacks.discard.erase(_card)
	card_stacks.deck.push_back(_card)
	put_discard_in_deck.emit(_card)
	
func draw_card():
	if card_stacks.deck.is_empty():
		print("empty deck")
		if card_stacks.discard.is_empty():
			print("empty discard")
			return
		
		var discard_amount = card_stacks.discard.size()
		
		for i in range(discard_amount):
			await replenish(card_stacks.discard[0])
			await get_tree().create_timer(.125).timeout
			
		card_stacks.deck.shuffle()
		
	var card_to_hand = card_stacks.deck.pop_back()
	#create_card.emit(card_to_hand)
	card_stacks.player_hand.push_back(card_to_hand)
	move_card_deck_to_hand.emit(card_to_hand, card_stacks.deck.size())

'func discard_card(_card_to_discard: Card = null):
	var card_to_discard
	
	if(card_stacks.player_hand.size()):
		card_to_discard = card_stacks.player_hand.pop_at(index)
		card_stacks.discard.push_back(card_to_discard)
		move_card_hand_to_discard.emit(card_to_discard)'

func discard_card(_card_to_discard: Card):
		
	card_stacks.player_hand.erase(_card_to_discard)
	card_stacks.discard.push_back(_card_to_discard)
	move_card_hand_to_discard.emit(_card_to_discard)

func finish_player_turn():
	InputHandler.disable_all()
	
	var cards_amount = card_stacks.player_hand.size()
	for _i in range(cards_amount):
		await discard_card(card_stacks.player_hand[0])
		await get_tree().create_timer(.2).timeout
		
	change_turn()

func start_opponent_turn():
	for opponent in card_stacks.opponent_slots:
		# TODO opponent's actions
		opponent.execute()
	change_turn()

func change_turn():
	player_turn = !player_turn
	
	if(player_turn):
		start_player_turn()
	else:
		start_opponent_turn()

func needs_a_target(card: Card) -> bool:
	var needed = false
	for effect in card.effects:
		needed = needed or (effect.type == Effect.Type.Damage)
		if(needed):
			break
	return needed
