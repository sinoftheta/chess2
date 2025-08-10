extends Node

const GRID_SIZE:float = 48
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
	play,
	shop,
	sell,
	bonus,
	none,
}

enum AbilityID {
	## I'm not implementing these yet
}

enum UnitType {
	attacker,
	healer,
	multiplier,
	boss,
	#empty, so we can use its AOE for an effect or something idk
}
enum UnitID {
	test_attacker,
	test_healer,
	test_multiplier,
	test_boss,
}
var unit_data:Dictionary[UnitID,UnitData] = {
	UnitID.test_attacker: UnitData.new(
		"test attacker",  ## title
		UnitType.attacker, ## type
		AOE_KERNEL_1x1_MOORE,## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_attack.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_healer: UnitData.new(
		"test healer",  ## title
		UnitType.healer, ## type
		AOE_KERNEL_1x1_MOORE,## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_heal.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_multiplier: UnitData.new(
		"test multiplier",  ## title
		UnitType.healer, ## type
		AOE_KERNEL_1x1_MOORE,## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_mult.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_boss: UnitData.new(
		"test boss",  ## title
		UnitType.boss, ## type
		[],## aoe
		false, ## is_aoe_absolute
		[], ## base_abilities.
		10, ## base_health
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_mult.png"), ## texture
		#null ## tooltip_texture
	),
}

enum ShopRarity {
	unavailable,
	common,
	uncommon,
	rare,
}


enum Menu {
	none,
	main,
	gameplay,
	options
}

const AOE_KERNEL_1x1_VON:Array[Vector2i] = [
					 Vector2i( 0,-1),
	Vector2i(-1, 0),                  Vector2i( 1, 0),
					 Vector2i( 0, 1),
]
const AOE_KERNEL_1x1_MOORE:Array[Vector2i] = [
	Vector2i(-1,-1), Vector2i( 0,-1), Vector2i( 1,-1),
	Vector2i(-1, 0),                  Vector2i( 1, 0),
	Vector2i(-1, 1), Vector2i( 0, 1), Vector2i( 1, 1),
]
