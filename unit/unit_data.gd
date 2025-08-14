class_name UnitData

var title:String
var description:String
var type:Constants.UnitType
var aoe:Array[Vector2i]
var aoe_is_absolute:bool
var base_health:float
var base_stat:float
var shop_rarity:Constants.ShopRarity
var base_shop_price:int
var texture:Texture2D
#var tooltip_texture:Texture2D

func _init(
	_title:String,
	_description:String,
	_type:Constants.UnitType,
	_aoe:Array[Vector2i],
	_aoe_is_absolute:bool,
	_base_health:int,
	_base_stat:float,
	_shop_rarity:Constants.ShopRarity,
	_base_shop_price:int,
	_texture:Texture2D,
	#_tooltip_texture:Texture2D,
) -> void:
	title           = _title
	description     = _description
	type            = _type
	aoe             = _aoe
	aoe_is_absolute = _aoe_is_absolute
	base_health     = _base_health
	base_stat       = _base_stat
	shop_rarity     = _shop_rarity
	base_shop_price = _base_shop_price
	texture         = _texture
	#tooltip_texture = _tooltip_texture
