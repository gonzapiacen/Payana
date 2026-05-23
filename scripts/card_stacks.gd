extends RefCounted
class_name CardStacks

var deck : Array[Card]
var discard : Array[Card]
var player_hand : Array[Card]
var permanent_slots : Array[Card] = [null, null, null]
var opponent_slots : Array[Opponent] = [null, null, null]
