extends Resource
class_name Card

enum Type{Instant, Permanent}

@export var image: CompressedTexture2D
@export var cost: int
@export var effects: Array[Effect]
@export var type: Type
@export var info: CardInfo

func set_info(_info_card: Resource):
	image = _info_card.image
	cost = _info_card.cost
	effects = _info_card.effects
	type = _info_card.type
	info = _info_card.info
