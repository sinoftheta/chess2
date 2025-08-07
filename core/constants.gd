extends Node

const GRID_SIZE:float = 32
const CENTER:Vector2i     = Vector2i.ZERO
const UP:Vector2i         = Vector2i( 0,-1)
const DOWN:Vector2i       = Vector2i( 0, 1)
const LEFT:Vector2i       = Vector2i(-1, 0)
const RIGHT:Vector2i      = Vector2i( 1, 0)
const UP_RIGHT:Vector2i   = UP   + RIGHT
const UP_LEFT:Vector2i    = UP   + LEFT
const DOWN_RIGHT:Vector2i = DOWN + RIGHT
const DOWN_LEFT:Vector2i  = DOWN + LEFT

enum BoardID {
	game,
	shop,
	sell,
}

enum AbilityID {
	## I'm not implementing these yet
}

enum UnitType {
	attacker,
	healer,
	multiplier,
	none,
}
enum UnitID {
	test_attacker,
	test_healer,
	test_multiplier,
	test_none,
}
var unit_data:Dictionary[UnitID,UnitData] = {
	UnitID.test_attacker: UnitData.new(
		"test attacker",  ## title
		UnitType.attacker, ## type
		[],## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		true, ## is_ally
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		null, ## texture
		null ## tooltip_texture
	),
	UnitID.test_healer: UnitData.new(
		"test healer",  ## title
		UnitType.healer, ## type
		[],## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		true, ## is_ally
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		null, ## texture
		null ## tooltip_texture
	),
}

enum ShopRarity {
	unavailable,
	common,
	uncommon,
	rare,
}
