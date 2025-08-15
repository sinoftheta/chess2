extends Node
const ANIMATION_TICK_TIME:float = 0.75

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


enum GamePhase {
	shop,
	#betting,
	end_of_turn,
	run_won,
	run_lost
}
enum BoardID {
	play,
	shop,
	sell,
	bonus,
	none,
}

## The UnitTypes are like the card evaluations in balatro, they are guarenteed to happen a finite amount of times
enum UnitType {
	attacker,
	healer,
	multiplier,
	boss,
	bonus
}
enum ShopRarity {
	unavailable,
	common,
	uncommon,
	rare,
}
var default_boss_pool:Array[UnitID]
var default_bonus_pool:Array[UnitID]
var default_common_shop_pool:Array[UnitID]
var default_uncommon_shop_pool:Array[UnitID]
var default_rare_shop_pool:Array[UnitID]
func _ready() -> void:
	for id:UnitID in UnitID.values():
		var data:UnitData = unit_data[id]
		match data.type:
			UnitType.boss:
				default_boss_pool.push_back(id)
			UnitType.bonus:
				default_bonus_pool.push_back(id)
			_:match data.shop_rarity:
				ShopRarity.common:
					default_common_shop_pool.push_back(id)
				ShopRarity.uncommon:
					default_uncommon_shop_pool.push_back(id)
				ShopRarity.rare:
					default_rare_shop_pool.push_back(id)


const type_descriptions:Dictionary[UnitType,String] = {
	UnitType.attacker:   "Deals its Stat as\ndamage to \ntarget units HP",
	UnitType.healer:     "Heals target units\nHP by its Stat",
	UnitType.multiplier: "Multiplies target\nunits Stat\nby its own Stat",
	UnitType.boss:       "Defeat this unit to\nwin the round!"
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
		"", ## description
		UnitType.attacker, ## type
		AOE_KERNEL_1x1_VON,## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_attack.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_healer: UnitData.new(
		"test healer",  ## title
		"", ## description
		UnitType.healer, ## type
		AOE_KERNEL_1x1_VON,## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_heal.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_multiplier: UnitData.new(
		"test multiplier",  ## title
		"", ## description
		UnitType.multiplier, ## type
		AOE_KERNEL_1x1_VON,## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.5, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_mult.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.test_boss: UnitData.new(
		"test boss",  ## title
		"deals 3 damage\nto each target", ## description
		UnitType.boss, ## type
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		5, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/test_boss.png"), ## texture
		#null ## tooltip_texture
	),
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

const AOE_BOSS_FULL_BOARD:Array[Vector2i] = [
	Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),
	Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),
	Vector2i(0,2),Vector2i(1,2),Vector2i(2,2),Vector2i(3,2),Vector2i(4,2),Vector2i(5,2),
	Vector2i(0,3),Vector2i(1,3),Vector2i(2,3),Vector2i(3,3),Vector2i(4,3),Vector2i(5,3),
	Vector2i(0,4),Vector2i(1,4),Vector2i(2,4),Vector2i(3,4),Vector2i(4,4),Vector2i(5,4),
	Vector2i(0,5),Vector2i(1,5),Vector2i(2,5),Vector2i(3,5),Vector2i(4,5),Vector2i(5,5),
]
