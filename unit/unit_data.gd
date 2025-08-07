class_name UnitData

var title:String
var type:Constants.UnitType
var aoe:Array[Vector2i]
var aoe_is_absolute:bool
var base_abilities:Array[Constants.AbilityID]
var base_health:int
var is_ally:bool
var shop_rarity:Constants.ShopRarity
var base_shop_price:int
var texture:Texture2D
var tooltip_texture:Texture2D

func _init(
	_title:String,
	_type:Constants.UnitType,
	_aoe:Array[Vector2i],
	_aoe_is_absolute:bool,
	_base_abilities:Array[Constants.AbilityID],
	_base_health:int,
	_is_ally:bool,
	_shop_rarity:Constants.ShopRarity,
	_base_shop_price:int,
	_texture:Texture2D,
	_tooltip_texture:Texture2D,
) -> void:
	title           = _title
	type            = _type
	aoe             = _aoe
	aoe_is_absolute = _aoe_is_absolute
	base_abilities  = _base_abilities
	base_health     = _base_health
	is_ally         = _is_ally
	shop_rarity     = _shop_rarity
	base_shop_price = _base_shop_price
	texture         = _texture
	tooltip_texture = _tooltip_texture
