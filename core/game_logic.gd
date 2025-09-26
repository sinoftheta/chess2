extends Node

var unit_tscn :PackedScene = preload("res://unit/unit.tscn")
var shop_rng  :RandomNumberGenerator
var boss_rng  :RandomNumberGenerator
var bonus_rng :RandomNumberGenerator
var combat_rng:RandomNumberGenerator
#region Setup
func _ready() -> void:
	SignalBus.start_game           .connect(_on_start_game)
	SignalBus.play_button_pressed  .connect(_on_play_button_pressed)
	SignalBus.next_turn_pressed    .connect(_on_next_turn_pressed)
	SignalBus.continue_run_pressed .connect(_on_continue_run_pressed)
	SignalBus.reroll_button_pressed.connect(_on_reroll_button_pressed)
	

func _on_start_game() -> void:
	#for id:Constants.BoardID in Constants.BoardID.values():
	#	print(Constants.BoardID.keys()[id], ": ", id)
	#print(boards)
	
	
	## game state
	board_evaluation_order = Constants.BOARD_EVAL_5X5_SPIRAL
	shop_rng   = RandomNumberGenerator.new()
	combat_rng = RandomNumberGenerator.new()
	bonus_rng  = RandomNumberGenerator.new()
	boss_rng   = RandomNumberGenerator.new()
	animating = false
	shop_size = 3
	round = 0
	turn = 0
	money = 5
	reroll_price = 3
	phase = Constants.GamePhase.shop
	
	## unit pools
	common_shop_pool     = Constants.default_common_shop_pool.duplicate()
	uncommon_shop_pool   = Constants.default_uncommon_shop_pool.duplicate()
	rare_shop_pool       = Constants.default_rare_shop_pool.duplicate()
	available_bonus_pool = Constants.default_bonus_pool.duplicate()
	
	## board setup
	for board:Board in boards.values():
		for unit:Unit in board.get_children():
			board.remove_child(unit)
			unit.queue_free()
	
	var start_unit:Unit = unit_tscn.instantiate()
	play_board.add_child(start_unit)
	start_unit.id = shop_rng.randi_range(Constants.UnitID.attacker1, Constants.UnitID.attacker3)
	var start_unit_positions:Array[Vector2i] = Util.string_to_aoe("
	x....
	.000.
	.0.0.
	.000.
	.....
	")
	start_unit.logical_position = start_unit_positions[boss_rng.randi_range(0, start_unit_positions.size() - 1)]
	
	spawn_bosses()
	#var start_boss:Unit = unit_tscn.instantiate()
	#play_board.add_child(start_boss)
	#start_boss.id = Constants.UnitID.boss1
	#var start_boss_positions:Array[Vector2i] = Util.string_to_aoe("
	#x.....
	#......
	#..00..
	#..0...
	#......
	#......
	#")
	#start_boss.logical_position = start_boss_positions[shop_rng.randi_range(0, start_boss_positions.size() - 1)]
	
	#update_unit_order_badges()
	cycle_shop()
	
	SignalBus.game_started.emit()
#endregion


#region Boards

var board_evaluation_order:Array[Vector2i]




var boards:Dictionary[Constants.BoardID,   Board]
var play_board:Board: 
	get(): return boards[Constants.BoardID.play ]
var shop_board:Board: 
	get(): return boards[Constants.BoardID.shop]

var sell_board:Board: 
	get(): return boards[Constants.BoardID.sell ]

func board_has_coord(board_id:Constants.BoardID, coord:Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO,boards[board_id].logical_size).has_point(coord)

	
#endregion

#region Animation
var tween:Tween
var animating:bool:
	set(value):
		var prev:bool = animating
		animating = value
		if value != prev:
			SignalBus.animating_state_updated.emit(value)

var tile_managers:Dictionary[Constants.BoardID, TileManager]
var play_tile_manager:TileManager:
	get(): return tile_managers[Constants.BoardID.play]

#var attacker_shop_tile_manager:TileManager:
	#get(): return tile_managers[Constants.BoardID.attacker_shop]
#
#var adder_shop_tile_manager:TileManager:
	#get(): return tile_managers[Constants.BoardID.attacker_shop]
#var healer_shop_tile_manager:TileManager:
	#get(): return tile_managers[Constants.BoardID.attacker_shop]

#endregion

#region Run State


var max_rounds:int = 14
var shop_size:int = 2
var round:int:
	set(value):
		round = value
		#print("turn ", value)
		SignalBus.round_changed.emit(value)
var turn:int:
	set(value):
		turn = value
		SignalBus.turn_changed.emit(value)
var money:int:
	set(value):
		var prev:int = money
		money = value
		SignalBus.money_changed.emit(value,prev)
var reroll_price:int:
	set(value):
		reroll_price = value
		SignalBus.reroll_price_changed.emit(value)
var phase:Constants.GamePhase:
	set(value):
		phase = value
		SignalBus.phase_changed.emit(value)
#endregion
#region turn statistics
#var turn_boss_damage:Array[int] = []
var turn_dead_allies:Array[int]
var turn_dead_bosses:Array[int]
#endregion

#region Unit pools

var common_shop_pool:Array[Constants.UnitID]
var uncommon_shop_pool:Array[Constants.UnitID]
var rare_shop_pool:Array[Constants.UnitID]
var available_bonus_pool:Array[Constants.UnitID]
var unlocked_bonus_pool:Array[Constants.UnitID]
#endregion

#region helpers
func unit_at(coord:Vector2i, board_id:Constants.BoardID) -> Unit:
	if board_id == Constants.BoardID.none: return null
	return boards[board_id].get_node_or_null(Util.coord_to_name(coord))

func is_unit_alive(unit:Unit) -> bool:
	return not unit.dead
#endregion

#region Game logic
func update_unit_order_badges(updated_unit:Unit = null, updated_coords:Vector2i = Vector2i(-1,-1)) -> void:
	var i:int = 0
	for eval_coord:Vector2i in board_evaluation_order:
		
		
		var unit:Unit = unit_at(eval_coord, Constants.BoardID.play)
		#if eval_coord == updated_coords: ## NOT IMPORTANT RIGHT NOW
			#pass
		#else:
			#
			#if unit == updated_unit: continue
		
		if not unit: continue
			
		i += 1
		unit.animated_play_order = i
	
	for unit:Unit in shop_board.get_children():
		unit.animated_play_order = 0

func move_unit(unit:Unit, to_board_id:Constants.BoardID, to_coord:Vector2i) -> void:
	
	var from_board:Board             = unit.get_parent()
	var from_coord:Vector2i          = unit.logical_position
	var to_board:Board               = boards[to_board_id]
	var same_boards:bool             = to_board == from_board
	
	if animating: return
	if phase != Constants.GamePhase.shop: return
	
	var unit_at_destination:Unit = unit_at(to_coord,to_board.id)
	if unit_at_destination == unit:
		## unit has not moved
		return
	if Constants.unit_data[unit.id].type == Constants.UnitType.boss:
		return
	#if to_board == shop_board and from_board == play_board:
		#SignalBus.message_under_cursor.emit("Can't go back in shop")
		#return
	if unit_at_destination:
		SignalBus.message_under_cursor.emit("Space occupied")
		return
	if not board_has_coord(to_board.id, to_coord): 
		SignalBus.message_under_cursor.emit("Out of bounds")
		return
	#if to_board == sell_board and from_board == shop_board:
		#SignalBus.message_under_cursor.emit("Thats not yours!")
		#return
	if to_board == play_board and from_board == shop_board:
		if money < unit.buy_price:
			SignalBus.message_under_cursor.emit("Not enough money")
			return
		money -= unit.buy_price
		

			
	#if to_board == sell_board:
		#
		### check if selling last remaining ally
		#var allies_remaining:int = 0
		### update unit data
		#for unit_in_play:Unit in play_board.get_children():
			#
			##print(Constants.UnitType.keys()[Constants.unit_data[unit_in_play.id].type])
			#
			#match Constants.unit_data[unit_in_play.id].type:
				#Constants.UnitType.boss:
					#pass
				#_: allies_remaining += 1
		#
		##print(allies_remaining)
		#
		#if allies_remaining == 1:
			#SignalBus.message_under_cursor.emit("That's your last Fighter!")
			#return
		#
		#SignalBus.unit_sold.emit(unit.sell_price)
		#money += unit.sell_price
		
	
	var gp:Vector2 = unit.global_position
	

	if not same_boards:
		from_board.remove_child(unit)
		to_board.add_child(unit)
	unit.logical_position = to_coord
	unit.global_position  = gp
	
	SignalBus.unit_moved.emit(unit, from_coord, from_board)
	
	#if to_board == sell_board:
		#unit.queue_free()
	
	update_unit_order_badges()
		
	#update_moves_made()

var animation_tick :int = 0
var unit_evaluation_order:Array[Unit]
var boss_units:Array[Unit]
func _on_play_button_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.shop: return
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	animating = true
	
	## we could also do this at the end of the animation
	clear_shop()

	animation_tick = 0
	
	var next_phase:Constants.GamePhase = Constants.GamePhase.end_of_turn
	
	## keep track of boss units
	boss_units.clear()
	var boss_init_hp:Array[int] = []
	for unit:Unit in play_board.get_children():
		if Constants.unit_data[unit.id].type == Constants.UnitType.boss:
			boss_units.push_back(unit)
			boss_init_hp.push_back(unit.hp)
	#print("boss units: ", boss_units)
	
	## lock in the unit_evaluation_order for this turn
	## evaluate each tile on the board
	var unit_tile_evaluation_index:Array[int] = []
	unit_evaluation_order.clear()
	for i:int in board_evaluation_order.size():
		var eval_coord:Vector2i = board_evaluation_order[i]
		var unit:Unit = unit_at(eval_coord, Constants.BoardID.play)
		if not unit: continue
		
		unit_evaluation_order.push_back(unit)
		unit.play_order = unit_evaluation_order.size()
		unit_tile_evaluation_index.push_back(i)
	
	game_event_pre_board_evaluation()
	
	## evaluate each unit on the board in order
	for i:int in unit_evaluation_order.size():
		var unit:Unit = unit_evaluation_order[i]
		if unit.dead: continue
		var unit_data:UnitData = Constants.unit_data[unit.id]
		
		## animate board chevrons up to this unit 
		play_tile_manager.animate_chevrons_forward(
			tween, animation_tick,
			(unit_tile_evaluation_index[i] + 0.5) / board_evaluation_order.size()
		)
		animation_tick += 1
		
		## evaluate each target_unit in the units AoE
		var valid_targets:Array[Unit] = []
		for aoe_coord:Vector2i in unit_data.aoe:
			var targeted_coord:Vector2i = aoe_coord
			if not unit_data.aoe_is_absolute:
				targeted_coord += unit.logical_position
			
			var targeted_unit:Unit = unit_at(targeted_coord, Constants.BoardID.play)
			
			## TODO: game_effect_unit_targeted() -> bool: (returns if its a valid target I guess) could be cool
			## unit abilities should be able to influence target determination
			
			if not targeted_unit: continue
			if targeted_unit == unit: continue
			if targeted_unit.dead: continue
			valid_targets.push_back(targeted_unit)
		
		if valid_targets.size() > 0:
			unit.animate_type_activation(tween, animation_tick)
		else:
			unit.animate_type_activation(tween, animation_tick) ## temp
			#unit.animate_type_miss(tween,animation_tick)
			pass
		animation_tick  += 1 ## in either case (miss or hit) we increase the animation tick
		

		for affected_unit:Unit in valid_targets:
			var affected_coord:Vector2i = affected_unit.logical_position
			if affected_unit.dead: continue
		
			match unit_data.type:
				Constants.UnitType.attacker:
					var prev_hp:int = affected_unit.hp
					
					## apply the damage
					affected_unit.hp = maxi(affected_unit.hp - unit.stat, 0.0)
					
					## animate
					affected_unit.animate_attacked(tween, animation_tick, unit.logical_position, prev_hp)

				Constants.UnitType.healer:
					## healing increases max hp
					var prev_hp:int = affected_unit.hp
					var prev_max_hp:int = affected_unit.max_hp
					
					affected_unit.hp = affected_unit.hp + unit.stat
					if affected_unit.max_hp < affected_unit.hp:
						affected_unit.max_hp = affected_unit.hp
					
					affected_unit.animate_healed(tween, animation_tick, unit.logical_position, prev_hp)
				Constants.UnitType.adder:
					var prev_stat:int = affected_unit.stat
					affected_unit.stat += unit.stat
					affected_unit.animate_added(tween, animation_tick, unit.logical_position, unit.stat)
				Constants.UnitType.multiplier:
					var prev_stat:int = affected_unit.stat
					affected_unit.stat *= unit.stat
					affected_unit.animate_multiplied(tween, animation_tick, unit.logical_position, unit.stat)
				Constants.UnitType.boss:
					apply_boss_effect(unit, affected_unit)
		
		## check if any of the targets died
		## dead units all share the same animation tick
		var dead_units:Array[Unit] = []
		for affected_unit:Unit in valid_targets:
			if affected_unit.dead: continue
			if affected_unit.hp == 0 and game_event_unit_pre_death(affected_unit):
				affected_unit.dead = true
				dead_units.push_back(affected_unit)

		for dead_unit:Unit in dead_units:
			dead_unit.animate_dead(tween, animation_tick)
		if dead_units.size() > 0: animation_tick  += 1
		
		for dead_unit:Unit in dead_units:
			game_event_unit_died(dead_unit)
		
	
	## count total boss damage dealt
	#turn_boss_damage.push_back(0.0)
	#for i:int in range(boss_units.size()):
		#turn_boss_damage[turn_boss_damage.size() - 1] += boss_init_hp[i] - boss_units[i].hp
	
	## animate board chevrons to the end
	play_tile_manager.animate_chevrons_forward(tween, animation_tick, 1.0)
	animation_tick += 2
	
	## reset chevron animation
	play_tile_manager.animate_chevrons_reset(tween, animation_tick)
	animation_tick += 1
	
	var boss_remaining  :int = 0
	var allies_remaining:int = 0
	## update unit data
	for unit:Unit in play_board.get_children():
		unit.turns_in_play += 1
		unit.prev_logical_position = unit.logical_position
		if not unit.dead:
			match Constants.unit_data[unit.id].type:
				Constants.UnitType.boss:
					boss_remaining += 1
				_:
					allies_remaining += 1
	
	tween.tween_callback(func () -> void: 
		animating = false
		## check for dead units and delete them
		for unit:Unit in play_board.get_children():
			if unit.dead:
				play_board.remove_child(unit)
				unit.queue_free()
		
		if allies_remaining == 0:
			next_phase = Constants.GamePhase.run_lost
		elif boss_remaining == 0:
			round += 1
			
			if round == max_rounds:
				next_phase = Constants.GamePhase.run_won
			
			spawn_bosses()
				
		turn += 1
		
		phase = next_phase

	).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
func _on_reroll_button_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.shop: return
	
	if money < reroll_price:
		SignalBus.cant_afford_reroll.emit()
		SignalBus.message_under_cursor.emit("Not enough money!")
		return

	money -= reroll_price
	reroll_price = reroll_price + 1
	
	game_event_rerolling_shop()
	
	clear_shop()
	cycle_shop()
	
	animating = true
	animating = false


func _on_next_turn_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.end_of_turn: return
	phase = Constants.GamePhase.shop
	
	#money += int(turn_boss_damage[turn_boss_damage.size() - 1])
	cycle_shop()

func _on_continue_run_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.run_won: return
	phase = Constants.GamePhase.end_of_turn

func clear_shop() -> void:
	## remove prev units
	for unit:Unit in shop_board.get_children():
		shop_board.remove_child(unit)
		unit.queue_free()
		
func spawn_bosses() -> Array[Unit]:
	## seems to be working
	var spawned_bosses:Array[Unit] = []
	#print("spawning boss for round ", round)
	
	var boss_stat:int = floori(log(round + 2)/log(2))
	var boss_hp:int = boss_stat * 10
	#print("boss base stat: ", boss_stat, ", hp: ", boss_hp)
	
	#print("num_bosses: ", num_bosses, ", stats: ", boss_stat, ", hp: ", boss_hp)
	
	## determine where we can spawn the dang guys
	var available_spawn_coords:Array[Vector2i]
	
	## will spawn over dead units
	for coord:Vector2i in board_evaluation_order:
		var unit:Unit = unit_at(coord, Constants.BoardID.play)
		if unit and not unit.dead: continue
		available_spawn_coords.push_back(coord)
	
	## determine the spawn coordinates
	var spawn_coords:Array[Vector2i] = []
	var i:int = 0
	
	while spawn_coords.size() < Constants.boss_levels_per_round[round].size():
		if boss_rng.randi_range(0,99) > 50:
			spawn_coords.push_back(available_spawn_coords[i])
			available_spawn_coords.remove_at(i)
		i = (i + 1) % available_spawn_coords.size()
	
	i = 0
	while i < spawn_coords.size():
		var coord:Vector2i = spawn_coords[i]
		var boss_level:int = Constants.boss_levels_per_round[round][i]
		var boss_id:Constants.UnitID = Constants.boss_level_pools[boss_level][
			boss_rng.randi_range(
				0,
				Constants.boss_level_pools[boss_level].size() - 1
			)
		]
		
		var unit:Unit = unit_tscn.instantiate()
		play_board.add_child(unit)
		
		unit.id = boss_id
		unit.init_stat = boss_stat
		
		unit.hp = boss_hp
		unit.animated_hp = boss_hp
		unit.logical_position = coord
		
		spawned_bosses.push_back(unit)
		i += 1
		
	update_unit_order_badges()
	
	return spawned_bosses

##TODO: this will be animated?
func cycle_shop() -> void:
	## generate new shop contents
	var shop_coords:Array[Vector2i] = [
		Vector2i(0,0),Vector2i(1,0),
		Vector2i(0,1),Vector2i(1,1)
	]
	shop_coords.shuffle()
	var shop_contents:Array[Constants.UnitID]
	for i:int in range(shop_size):
		
		## choose the rarity of the unit
		var rarity:int = shop_rng.randi_range(0,99)
		var selected_pool:Array[Constants.UnitID]
		if   rarity < 92:
			#print("gen shop common")
			selected_pool = common_shop_pool
		elif rarity < 97:
			#print("gen shop uncommon")
			selected_pool = uncommon_shop_pool
		else:
			#print("gen shop rare") 
			selected_pool = rare_shop_pool
		
		## filter the pool
		var filtered_pool:Array[Constants.UnitID] = selected_pool.duplicate()
		
		## filter the board contents from the pool
		for unit:Unit in play_board.get_children():
			## filter the id from the pool by swapping the element to the back and popping it
			var filter_index:int = filtered_pool.find(unit.id)
			if filter_index != -1:
				var temp:Constants.UnitID = filtered_pool.back()
				filtered_pool[filtered_pool.size() - 1] = filtered_pool[filter_index]
				filtered_pool[filter_index] = temp
				filtered_pool.pop_back()
		
		## filter the shop contents from the pool
		for id:Constants.UnitID in shop_contents:
			## filter the id from the pool by swapping the element to the back and popping it
			var filter_index:int = filtered_pool.find(id)
			if filter_index != -1:
				var temp:Constants.UnitID = filtered_pool.back()
				filtered_pool[filtered_pool.size() - 1] = filtered_pool[filter_index]
				filtered_pool[filter_index] = temp
				filtered_pool.pop_back()
				
		if filtered_pool.size() > 0:
			var rand_index:int = shop_rng.randi_range(0, filtered_pool.size() - 1)
			shop_contents.push_back(filtered_pool[rand_index])
		elif selected_pool.size() > 0:
			#print("shop filtering failed")
			shop_contents.push_back(selected_pool[0])
		else:
			pass
			#print("no units of that rarity")
			#shop_contents.push_back(Constants.UnitID.test_attacker)
	
	for id:Constants.UnitID in shop_contents:
		var unit:Unit = unit_tscn.instantiate()
		shop_board.add_child(unit)
		unit.id = id
		unit.logical_position = shop_coords.pop_back()
	
	update_unit_order_badges()
func cycle_bonus() -> void:
	pass
#endregion

#region Boss mechanics
func apply_boss_effect(boss_unit:Unit, affected_unit:Unit) -> void:
	## bosses do not effect other bosses
	#game_event_pre_boss_effect_application()
	# maybe some ability could make bosses hurt each other but do double damage to your units
	if affected_unit.data.type == Constants.UnitType.boss: return
	
	var prev_hp:int = affected_unit.hp
	
	match boss_unit.id:
		Constants.UnitID.catface:
			## deals 2 damage to each of your mons
			affected_unit.hp = maxi(0, affected_unit.hp - 2)
		Constants.UnitID.dumpling:
			## deals each mon
			print("affected units play order: ", affected_unit.play_order)
			affected_unit.hp = maxi(0, affected_unit.hp - affected_unit.play_order)
	
	affected_unit.animate_attacked(
		tween, animation_tick, 
		boss_unit.logical_position, prev_hp
	)
#endregion

#region game event responses
func game_event_rerolling_shop() -> void:
	for unit:Unit in unit_evaluation_order:
		##TODO: there should be no dead units at this point
		## checking for .dead should be redundant
		if unit.dead :continue 
		match unit.id:
			pass
func game_event_pre_board_evaluation() -> void:
	for unit:Unit in unit_evaluation_order:
		if unit.dead :continue ## there should be no dead units at this point
		match unit.id:
			pass

func game_event_unit_pre_death(affected_unit:Unit) -> bool:
	var prevent_unit_death:bool = false
	for unit:Unit in unit_evaluation_order:
		if unit == affected_unit:continue
		if unit.dead :continue
		match unit.id:
			pass
	return not prevent_unit_death

func game_event_unit_died(dead_unit:Unit) -> void:
	for unit:Unit in unit_evaluation_order:
		if unit.dead: continue
		
		match unit.id:
			Constants.UnitID.attacker1:
				## "Deals one damage to a random enemy whenever an allied monster dies"
				if dead_unit.data.type == Constants.UnitType.boss: continue
				var alive_boss_units:Array[Unit] = boss_units.filter(is_unit_alive)
				if alive_boss_units.size() == 0: continue
				print("applying UnitID.attacker1 effect damage to a boss")
				#
				### select the unit
				#var boss_unit:Unit = alive_boss_units[
					#combat_rng.randi_range(0, alive_boss_units.size())
				#]
				#
				### gonna have to make damage application & death checking into functions
				#boss_unit
				#var prev_hp:int = boss_unit.hp
				#
				### apply the damage
				#boss_unit.hp = maxi(boss_unit.hp - 1, 0)
				#
				### animate
				#boss_unit.animate_attacked(tween, animation_tick, unit.logical_position, prev_hp)
				
				
					

#endregion


## the ONLY way you can heal has to be from healers
## nothing that triggers from playing a round can heal ("no mid round healing")
## gotta avoid infinite loops with healing that triggers damage that triggers healing and so on

## spiteful: when this unit takes damage, deal half that damage to a random monster (enimy or ally) on the board


## terminology: 
## every unit is a Monster
## your Monsters are called Allied Monsters or Allies
## the bosses are Enimy Monsters aka Enimies
## Monsters can be KO'd
## when a Monster's HP reaches 0, it is KO'd (absent any Effect that may change this)
## Monsters can also be KO'd by some Effects
## Monsters have a Type and sometimes an Effect
## each Effect is associated with a unique Monster
## Monsters have HP
## Monsters have a Base Stat (the starting value of their Live Stat each Turn)
## Monsters have a Live Stat (Live Stat updates during the Turn and is used in board evaluation)
## Monsters have an AoE
## The Player can Clear Rounds
## The Player Wins by Clearing Round 14
## The Player can KO all Enimy Monsters to Advance to the next Round
