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
	adder,
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
	
	#print(Util.string_to_aoe("
		#000
		#0x0
		#000
#"))
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
	UnitType.attacker:   "Deals it's Stat as\ndamage to \ntarget units HP",
	UnitType.healer:     "Heals target units\nHP by its Stat",
	UnitType.multiplier: "Multiplies target\nunits Stat\nby its own Stat",
	UnitType.adder:      "Adds it's Stat to\ntarget units Stat",
	UnitType.boss:       "Defeat this unit to\nwin the round!"
}
enum UnitID {
	
	boss1,
	boss2,
	boss3,
	
	adder1,
	adder2,
	adder3,
	adder4,
	#adder5,
	#adder6,
	#adder7,
	
	attacker1,
	attacker2,
	attacker3,
	#attacker4,
	#attacker5,
	#attacker6,
	#attacker7,
	
	#healer1,
	#healer2,
	#healer3,
	#healer4,
	#healer5,
	#healer6,
	#healer7,
	#healer8,
	
	mult1,
	mult2,
	#mult3,
	#mult4,
	#mult5,
	#mult6,
	#mult7
}
var unit_data:Dictionary[UnitID,UnitData] = {

	UnitID.boss1: UnitData.new(
		"Cat",  ## title
		"Deals 3 damage to each target", ## description
		UnitType.boss, ## type
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/cat.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.boss2: UnitData.new(
		"Brute",  ## title
		"Deals damage equal to the target's distance from the boss", ## description
		UnitType.boss, ## type
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/brute.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.boss3: UnitData.new(
		"Dram",  ## title
		"Deals damage equal to the target's move order", ## description
		UnitType.boss, ## type
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/dram.png"), ## texture
		#null ## tooltip_texture
	),
	
	
	
	
	
	
	UnitID.adder1: UnitData.new(
		"Plomp",  ## title
		"", ## description
		UnitType.adder, ## type
		Util.string_to_aoe("
		0..
		.x0
		.0."),## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/plomp.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.adder2: UnitData.new(
		"Wat",  ## title
		"", ## description
		UnitType.adder, ## type
		Util.string_to_aoe("
		..0
		0x.
		.0."),## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/wat.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.adder3: UnitData.new(
		"Wot",  ## title
		"", ## description
		UnitType.adder, ## type
		Util.string_to_aoe("
		.0.
		0x.
		..0"),## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/wot.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.adder4: UnitData.new(
		"Mumpo",  ## title
		"", ## description
		UnitType.adder, ## type
		Util.string_to_aoe("
		.0.
		.x0
		0.."),## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/mumpo.png"), ## texture
		#null ## tooltip_texture
	),
	
	
	UnitID.attacker1: UnitData.new(
		"Krata",  ## title
		"", ## description
		UnitType.attacker, ## type
		Util.string_to_aoe("
		..0..
		..0..
		00x00
		..0..
		..0.."),## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/krata.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.attacker2: UnitData.new(
		"Frum",  ## title
		"", ## description
		UnitType.attacker, ## type
		Util.string_to_aoe("
		0...0
		.0.0.
		..x..
		.0.0.
		0...0"),## aoe
		false,# is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/frum.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.attacker3: UnitData.new(
		"Klat",  ## title
		"", ## description
		UnitType.attacker, ## type
		Util.string_to_aoe("
		.0.0.
		0...0
		..x..
		0...0
		.0.0."),## aoe
		false,# is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		1,  ## base_shop_price
		load("res://texture/units/clat.png"), ## texture
		#null ## tooltip_texture
	),
	
	
	
	UnitID.mult1: UnitData.new(
		"Tomo",  ## title
		"", ## description
		UnitType.multiplier, ## type
		[Vector2i(1,1),Vector2i(-1,-1)],## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.5, ## base stat
		ShopRarity.uncommon, ## shop_rarity
		5,  ## base_shop_price
		load("res://texture/units/tomo.png"), ## texture
		#null ## tooltip_texture
	),
	UnitID.mult2: UnitData.new(
		"Spine",  ## title
		"", ## description
		UnitType.multiplier, ## type
		[Vector2i(1,-1),Vector2i(-1,1)],## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.5, ## base stat
		ShopRarity.uncommon, ## shop_rarity
		5,  ## base_shop_price
		load("res://texture/units/spine.png"), ## texture
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

const AOE_KERNEL_TRI1:Array[Vector2i] = [
	Vector2i(-1,-1), 
									Vector2i(1,0),
					Vector2i(0,1)
]
const AOE_KERNEL_TRI2:Array[Vector2i] = [
									Vector2i(1,-1),
	Vector2i(-1,0),
					Vector2i(0,1)
]
const AOE_KERNEL_TRI3:Array[Vector2i] = [
					Vector2i(0,-1),
									Vector2i(1,0),
	Vector2i(-1,1)
]
const AOE_KERNEL_TRI4:Array[Vector2i] = [
					Vector2i(0,-1),
	Vector2i(-1,0),
									Vector2i(1,1)
]

const test_aoe_string:String =\
"
. 0 .
. x .
. 0 0"

const AOE_KERNEL_BIGTRI1:Array[Vector2i] = []
const AOE_KERNEL_BIGTRI2:Array[Vector2i] = []
const AOE_KERNEL_BIGTRI3:Array[Vector2i] = []
const AOE_KERNEL_BIGTRI4:Array[Vector2i] = []

const AOE_BOSS_FULL_BOARD:Array[Vector2i] = [
	Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),
	Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),Vector2i(5,1),
	Vector2i(0,2),Vector2i(1,2),Vector2i(2,2),Vector2i(3,2),Vector2i(4,2),Vector2i(5,2),
	Vector2i(0,3),Vector2i(1,3),Vector2i(2,3),Vector2i(3,3),Vector2i(4,3),Vector2i(5,3),
	Vector2i(0,4),Vector2i(1,4),Vector2i(2,4),Vector2i(3,4),Vector2i(4,4),Vector2i(5,4),
	Vector2i(0,5),Vector2i(1,5),Vector2i(2,5),Vector2i(3,5),Vector2i(4,5),Vector2i(5,5),
]
