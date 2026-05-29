extends Node

func enable_player_action():
	_enable_player_hand()
	_enable_pass()

func disable_all():
	_disable_pass()
	_disable_player_hand()
	_disable_opponent_cards()

func enable_opponent_cards():
	pass

func _enable_player_hand():
	pass

func _enable_opponent_cards():
	pass

func _enable_pass():
	pass

func _disable_opponent_cards():
	pass

func _disable_player_hand():
	pass

func _disable_pass():
	pass

func enable_only_map():
	# TODO enable map and nodes for player to select next scene
	pass
