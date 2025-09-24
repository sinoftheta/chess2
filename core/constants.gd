extends Node
const ANIMATION_TICK_TIME:float = 0.75

const CENTER:Vector2i     = Vector2i.ZERO
const UP:Vector2i         = Vector2i( 0,-1)
const DOWN:Vector2i       = Vector2i( 0, 1)
const LEFT:Vector2i       = Vector2i(-1, 0)
const RIGHT:Vector2i      = Vector2i( 1, 0)
const UP_RIGHT:Vector2i   = UP   + RIGHT
const UP_LEFT:Vector2i    = UP   + LEFT
const DOWN_RIGHT:Vector2i = DOWN + RIGHT
const DOWN_LEFT:Vector2i  = DOWN + LEFT


## each boss is put into a "level_pool" based on the difficulty I associate with its effect

const boss_levels_per_round:Array[Array] = [
	[1], ## pipsqueak m'gee
	[1,1],
	[2],
	[2,1],
	[2,1,1],
	[2,2],
	[3],
	[3,1],
	[3,1,1],
	[3,2],
	[3,2,1],
	[3,2,1,1],
	[3,2,2],
	[3,3],
	[4], ## bellua them-fucking-self
	## beyond this is endless mode
	## I will continue the pattern of the number of bosses increasing, 
	## but the level pools won't increase and will eventually just all be 4
	
	## HOWEVER the stat and HP will increase
	[4,1],
	[4,1,1],
	[4,2],
	[4,2,1],
	[4,2,1,1],
	[4,2,2],
	[4,3],
	[4,3,1],
	[4,3,1,1],
	[4,3,2],
	[4,3,2,1],
	[4,3,2,1,1],
	[4,3,2,2],
	[4,3,3],
	[4,4],
	
	## the pattern breaks here
	[4,4,1],
	[4,4,1,1],
	[4,4,2],
	## and ect... I guess it goes until 25 bosses are on screen lol
	
]

enum GamePhase {
	shop,
	#betting,
	end_of_turn,
	apply_upgrade,
	#force_unit_culling,
	run_won,
	run_lost
}
enum BoardID {
	play,
	sell,
	none,
	
	attacker_shop,
	adder_shop,
	healer_shop
}

## The UnitTypes are like the card evaluations in balatro, they are guarenteed to happen a finite amount of times
enum UnitType {
	attacker,
	healer,
	multiplier,
	adder,
	boss,
	bonus,
	item
}
enum ShopRarity {
	unavailable,
	common,
	uncommon,
	rare,
}
var boss_level_pools:Dictionary[int, Array]
var default_bonus_pool:Array[UnitID]
var default_common_shop_pool:Array[UnitID]
var default_uncommon_shop_pool:Array[UnitID]
var default_rare_shop_pool:Array[UnitID]
func _ready() -> void:
	for id:UnitID in UnitID.values():
		var data:UnitData = unit_data[id]
		match data.type:
			UnitType.boss:
				if not boss_level_pools.has(data.boss_level_pool):
					boss_level_pools[data.boss_level_pool] = [id]
				else:
					boss_level_pools[data.boss_level_pool].push_back(id)
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
	UnitType.attacker:   "Deal own STAT as damage to targets HP",
	UnitType.healer:     "Heal targets HP by own STAT",
	UnitType.multiplier: "Multiply targets Stat by own STAT",
	UnitType.adder:      "Adds own STAT to targets STAT",
	UnitType.boss:       "Defeat this ENIMY to advance!",
	UnitType.item:       "Drag onto a target to use"
}
enum UnitID {
	
	catface,
	dumpling,
	leggy,
	brute,
	longhorn,
	totem,
	batface,
	squid,
	#boss4,
	
	adder1,
	adder2,
	adder3,
	adder4,
	#adder5,
	#adder6,
	#adder7,
	#adder8,
	
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
	
	#test_item
}
#var base_sprite_sheet:Texture2D = preload() 
var unit_data:Dictionary[UnitID,UnitData] = {
	UnitID.catface: UnitData.new(
		"Catface",  ## title
		"Deal own STAT as damage to targets HP", ## description
		UnitType.boss, ## type
		1, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		## I will probably have to change base stat and health to be round dependant
		10,   ## base_health
		3.0,  ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,1)
	),
	UnitID.dumpling: UnitData.new(
		"Dumpling",  ## title
		"Deals damage equal to the target's distance from Brute", ## description
		UnitType.boss, ## type
		1, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,2)
	),
	UnitID.leggy: UnitData.new(
		"Leggy",  ## title
		"Deals damage equal to the target's move order", ## description
		UnitType.boss, ## type
		2, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,3)
	),
	UnitID.brute: UnitData.new(
		"Brute",  ## title
		"placeholder", ## description
		UnitType.boss, ## type
		2, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,4)
	),
	UnitID.longhorn: UnitData.new(
		"Lornhorn",  ## title
		"placeholder", ## description
		UnitType.boss, ## type
		3, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,5)
	),
	UnitID.totem: UnitData.new(
		"Totem",  ## title
		"placeholder", ## description
		UnitType.boss, ## type
		3, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,6)
	),
	UnitID.batface: UnitData.new(
		"Batface",  ## title
		"placeholder", ## description
		UnitType.boss, ## type
		4, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,7)
	),
	UnitID.squid: UnitData.new(
		"Squid",  ## title
		"placeholder", ## description
		UnitType.boss, ## type
		4, ## boss level pool, must be 0 if unit is not a boss
		AOE_BOSS_FULL_BOARD,## aoe
		true, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.unavailable, ## shop_rarity
		1,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(0,8)
	),
	
	
	
	
	
	
	UnitID.adder1: UnitData.new(
		"Plomp",  ## title
		"", ## description
		UnitType.adder, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		Util.string_to_aoe("
		0..
		.x0
		.0."),## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	UnitID.adder2: UnitData.new(
		"Wat",  ## title
		"", ## description
		UnitType.adder, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		Util.string_to_aoe("
		..0
		0x.
		.0."),## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	UnitID.adder3: UnitData.new(
		"Wot",  ## title
		"", ## description
		UnitType.adder, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		Util.string_to_aoe("
		.0.
		0x.
		..0"),## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	UnitID.adder4: UnitData.new(
		"Mumpo",  ## title
		"", ## description
		UnitType.adder, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		Util.string_to_aoe("
		.0.
		.x0
		0.."),## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.0, ## base stat
		ShopRarity.common, ## shop_rarity
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	#UnitID.adder5: UnitData.new(
		#"Flom",  ## title
		#"", ## description
		#UnitType.adder, ## type
		#Util.string_to_aoe("
		#0.0
		#.x.
		#.0."),## aoe
		#false, ## is_aoe_absolute
		#10, ## base_health
		#1.0, ## base stat
		#ShopRarity.common, ## shop_rarity
		#3,  ## base_shop_price
		#load("res://texture/units/flom.png"), ## texture
		##null ## tooltip_texture
		
	#),
	#UnitID.adder6: UnitData.new(
		#"Melty",  ## title
		#"", ## description
		#UnitType.adder, ## type
		#Util.string_to_aoe("
		#0..
		#.x0
		#0.."),## aoe
		#false, ## is_aoe_absolute
		#10, ## base_health
		#1.0, ## base stat
		#ShopRarity.common, ## shop_rarity
		#3,  ## base_shop_price
		#load("res://texture/units/melt_rat.png"), ## texture
		##null ## tooltip_texture
	#),
	#UnitID.adder7: UnitData.new(
		#"plum",  ## title
		#"", ## description
		#UnitType.adder, ## type
		#Util.string_to_aoe("
		#.0.
		#.x.
		#0.0"),## aoe
		#false, ## is_aoe_absolute
		#10, ## base_health
		#1.0, ## base stat
		#ShopRarity.common, ## shop_rarity
		#3,  ## base_shop_price
		#load("res://texture/units/plum.png"), ## texture
		##null ## tooltip_texture
	#),
	#UnitID.adder8: UnitData.new(
		#"raggy",  ## title
		#"", ## description
		#UnitType.adder, ## type
		#Util.string_to_aoe("
		#..0
		#0x.
		#..0"),## aoe
		#false, ## is_aoe_absolute
		#10, ## base_health
		#1.0, ## base stat
		#ShopRarity.common, ## shop_rarity
		#3,  ## base_shop_price
		#load("res://texture/units/raggy.png"), ## texture
		##null ## tooltip_texture
	#),
	
	
	UnitID.attacker1: UnitData.new(
		"Krata",  ## title
		"", ## description
		UnitType.attacker, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
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
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(1,0)
	),
	UnitID.attacker2: UnitData.new(
		"Frum",  ## title
		"", ## description
		UnitType.attacker, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
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
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(1,1)
	),
	UnitID.attacker3: UnitData.new(
		"Klat",  ## title
		"", ## description
		UnitType.attacker, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
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
		3,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i(1,2)
	),
	
	
	
	UnitID.mult1: UnitData.new(
		"Tomo",  ## title
		"", ## description
		UnitType.multiplier, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		[Vector2i(1,1),Vector2i(-1,-1)],## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.5, ## base stat
		ShopRarity.uncommon, ## shop_rarity
		5,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	UnitID.mult2: UnitData.new(
		"Spine",  ## title
		"", ## description
		UnitType.multiplier, ## type
		0, ## boss level pool, must be 0 if unit is not a boss
		[Vector2i(1,-1),Vector2i(-1,1)],## aoe
		false, ## is_aoe_absolute
		10, ## base_health
		1.5, ## base stat
		ShopRarity.uncommon, ## shop_rarity
		5,  ## base_shop_price
		#null ## tooltip_texture
		Vector2i.ZERO
	),
	#UnitID.test_item: UnitData.new(
		#"Stat Milk",
		#"permanently adds 0.5 to the consumers STAT",
		#UnitType.item,
		#[Vector2.ZERO],
		#false,
		#0.0,
		#0.0,
		#ShopRarity.common,
		#3,
		#load("res://texture/units/stat_milk.png")
	#)
}



enum Menu {
	none,
	main,
	tutorial_1,
	tutorial_2,
	gameplay,
	options
}
const menu_data:Dictionary[Menu, Dictionary] = {
	Menu.none: {
		"scale":Vector2.ONE * 2,
		"position":Vector2.ZERO
	},
	Menu.main: {
		"scale":Vector2.ONE * 2,
		"position":Vector2.ZERO
	},
	Menu.gameplay: {
		"scale":Vector2.ONE * 3,
		"position":Vector2(20,-40)
	},
	Menu.options: {
		"scale":Vector2.ONE * 5,
		"position":Vector2.ZERO
	}
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

const BOARD_EVAL_5X5_SPIRAL:Array[Vector2i] = [
	Vector2i(2,2),Vector2i(3,2),Vector2i(3,3),Vector2i(2,3),Vector2i(1,3),
	Vector2i(1,2),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1),Vector2i(4,1),
	Vector2i(4,2),Vector2i(4,3),Vector2i(4,4),Vector2i(3,4),Vector2i(2,4),
	Vector2i(1,4),Vector2i(0,4),Vector2i(0,3),Vector2i(0,2),Vector2i(0,1),
	Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),
]


enum PipeSegmentType {
	start_to_right,
	#start_to_top,
	#start_to_left,
	#start_to_bottom,
	
	right_to_top,
	right_to_left,
	right_to_bottom,
	#right_to_end,
	
	top_to_right,
	top_to_left,
	top_to_bottom,
	#top_to_end,
	
	left_to_right,
	left_to_top,
	left_to_bottom,
	#left_to_end,
	
	bottom_to_right,
	bottom_to_top,
	bottom_to_left,
	#bottom_to_end,
	
}
enum TileType {
	start_to_right,
	start_to_top,
	start_to_left,
	start_to_bottom,
	
	right_to_top,
	right_to_left,
	right_to_bottom,
	right_to_end,
	
	top_to_right,
	top_to_left,
	top_to_bottom,
	top_to_end,
	
	left_to_right,
	left_to_top,
	left_to_bottom,
	left_to_end,
	
	bottom_to_right,
	bottom_to_top,
	bottom_to_left,
	bottom_to_end,
	
}
