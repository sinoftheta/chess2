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
	#SignalBus.reroll_button_pressed.connect(_on_reroll_button_pressed)
	

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
var healer_shop_board:Board: 
	get(): return boards[Constants.BoardID.healer_shop]
var attacker_shop_board:Board: 
	get(): return boards[Constants.BoardID.attacker_shop]
var adder_shop_board:Board: 
	get(): return boards[Constants.BoardID.adder_shop]

var sell_board:Board: 
	get(): return boards[Constants.BoardID.sell ]

func board_has_coord(board_id:Constants.BoardID, coord:Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO,boards[board_id].logical_size).has_point(coord)


func _process(delta: float) -> void:
	if !boards:return
	debug_spawn()
	debug_delete()
	
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
var turn_boss_damage:Array[float] = []
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
	return boards[board_id].get_node_or_null(Util.coord_to_name(coord))
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
		unit.play_order = i
	
	for unit:Unit in adder_shop_board.get_children():
		unit.play_order = 0
	for unit:Unit in attacker_shop_board.get_children():
		unit.play_order = 0
	for unit:Unit in healer_shop_board.get_children():
		unit.play_order = 0

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
		SignalBus.message_under_cursor.emit("Bosses can't move")
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
	if to_board == play_board and (
		from_board == attacker_shop_board or\
		from_board == healer_shop_board or\
		from_board == adder_shop_board
		):
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
var units_evaluated:int = 0
func _on_play_button_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.shop: return
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	animating = true
	
	## we could also do this at the end of the animation
	clear_shop()

	animation_tick = 0
	units_evaluated = 0
	
	var next_phase:Constants.GamePhase = Constants.GamePhase.end_of_turn
	
	## keep track of boss units
	var boss_units:Array[Unit] = []
	var boss_init_hp:Array[float] = []
	for unit:Unit in play_board.get_children():
		if Constants.unit_data[unit.id].type == Constants.UnitType.boss:
			boss_units.push_back(unit)
			boss_init_hp.push_back(unit.hp)
	#print("boss units: ", boss_units)
	
	## evaluate each tile on the board
	
	for i:int in board_evaluation_order.size():
		var eval_coord:Vector2i = board_evaluation_order[i]
		var unit:Unit = unit_at(eval_coord, Constants.BoardID.play)
		if not unit: continue
		if unit.dead: continue
		
		## animate tiles
		for tile:Tile in play_tile_manager.get_children():
			tween.tween_property(
				tile, "chevron_animation", 
				(i + 0.5) / board_evaluation_order.size(), 
				 Constants.ANIMATION_TICK_TIME
			).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
		animation_tick += 1
			
		
		
		var data:UnitData = Constants.unit_data[unit.id]
		
		assert(unit.logical_position == eval_coord)
		
		unit.animate_type_effect(tween, animation_tick, units_evaluated)
		
		## evaluate each coord in the units AoE
		
		## first, we check if any units are in the AoE
		## we do this so we can increase the animation tick for them
		var aoe_contains_target:bool = false
		for aoe_coord:Vector2i in data.aoe:
			var affected_coord:Vector2i = aoe_coord
			if not data.aoe_is_absolute:
				affected_coord += unit.logical_position
			
			var affected_unit:Unit = unit_at(affected_coord, Constants.BoardID.play)
			if affected_unit: 
				aoe_contains_target = true
				break

		if aoe_contains_target: animation_tick += 1
		
		var unit_died:bool = false
		for aoe_coord:Vector2i in data.aoe:
			var affected_coord:Vector2i = aoe_coord
			if not data.aoe_is_absolute:
				affected_coord += unit.logical_position
			
			var affected_unit:Unit = unit_at(affected_coord, Constants.BoardID.play)
			if not affected_unit:     continue
			if affected_unit.dead:    continue
			if unit == affected_unit: continue
			
			match data.type:
				Constants.UnitType.attacker,Constants.UnitType.boss:
					var prev_hp:float = affected_unit.hp
					
					## apply damage
					## boss effects check
					#match unit.id:
						#Constants.UnitID.boss2:
							### damage based on distance
							#var d:float = (
								#absf(unit.logical_position.x - affected_unit.logical_position.x) + 
								#absf(unit.logical_position.y - affected_unit.logical_position.y)
							#)
							#affected_unit.hp = maxf(affected_unit.hp - d * unit.stat, 0.0)
						#Constants.UnitID.boss3:
							##damage based on move order
							#affected_unit.hp = maxf(affected_unit.hp - affected_unit.play_order * unit.stat, 0.0)
						##Constants.UnitID.boss4:
							## inverse move order
							##affected_unit.hp = maxf(affected_unit.hp - (play_board.get_child_count() - affected_unit.play_order) * unit.stat, 0.0)
						#Constants.UnitID.boss1, _:
							#affected_unit.hp = maxf(affected_unit.hp - unit.stat, 0.0)
					#
					affected_unit.hp = maxf(affected_unit.hp - unit.stat, 0.0)
					
					## animate
					affected_unit.animate_attacked(tween, animation_tick, unit.logical_position, prev_hp)
					
					## check for death
					if affected_unit.hp == 0:
						unit_died = true
						affected_unit.animate_dead(tween, animation_tick)
						affected_unit.dead = true

				Constants.UnitType.healer:
					## healing increases max hp
					var prev_hp:float = affected_unit.hp
					var prev_max_hp:float = affected_unit.max_hp
					
					affected_unit.hp = affected_unit.hp + unit.stat
					if affected_unit.max_hp < affected_unit.hp:
						affected_unit.max_hp = affected_unit.hp
					
					affected_unit.animate_healed(tween, animation_tick, unit.logical_position, prev_hp)
				Constants.UnitType.adder:
					var prev_stat:float = affected_unit.stat
					affected_unit.stat += unit.stat
					affected_unit.animate_added(tween, animation_tick, unit.logical_position, unit.stat)
				Constants.UnitType.multiplier:
					var prev_stat:float = affected_unit.stat
					affected_unit.stat *= unit.stat
					affected_unit.animate_multiplied(tween, animation_tick, unit.logical_position, unit.stat)
					
		if unit_died: animation_tick  += 1
		animation_tick  += 1
		units_evaluated += 1
	
	## count total boss damage dealt
	turn_boss_damage.push_back(0.0)
	for i:int in range(boss_units.size()):
		turn_boss_damage[turn_boss_damage.size() - 1] += boss_init_hp[i] - boss_units[i].hp
	
	
	
	## reset chevron animation
	for tile:Tile in play_tile_manager.get_children():
		tween.tween_property(
			tile, "chevron_animation", 0, 
			 Constants.ANIMATION_TICK_TIME
		).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
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
	
	clear_shop()
	cycle_shop()
	
	animating = true
	animating = false


func _on_next_turn_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.end_of_turn: return
	phase = Constants.GamePhase.shop
	
	money += int(turn_boss_damage[turn_boss_damage.size() - 1])
	cycle_shop()

func _on_continue_run_pressed() -> void:
	if animating:return
	if phase != Constants.GamePhase.run_won: return
	phase = Constants.GamePhase.end_of_turn

func clear_shop() -> void:
	## remove prev units
	for unit:Unit in adder_shop_board.get_children():
		adder_shop_board.remove_child(unit)
		unit.queue_free()
		
	for unit:Unit in attacker_shop_board.get_children():
		attacker_shop_board.remove_child(unit)
		unit.queue_free()
		
	for unit:Unit in healer_shop_board.get_children():
		healer_shop_board.remove_child(unit)
		unit.queue_free()
		
func spawn_bosses() -> Array[Unit]:
	var spawned_bosses:Array[Unit] = []
	print("spawning boss for round ", round)
	
	var boss_stat:int = floori(log(round + 2)/log(2))
	var boss_hp:int = boss_stat * 10
	print("boss base stat: ", boss_stat, ", hp: ", boss_hp)
	
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
	
	#for id:Constants.UnitID in shop_contents:
	#	var unit:Unit = unit_tscn.instantiate()
	#	shop_board.add_child(unit)
	#	unit.id = id
	#	unit.logical_position = shop_coords.pop_back()
	
	update_unit_order_badges()
func cycle_bonus() -> void:
	pass
#endregion

#region Boss mechanics
func evaluate_boss(boss:Unit) -> void:
	for eval_coord:Vector2i in board_evaluation_order:
		var unit:Unit = unit_at(eval_coord, Constants.BoardID.play)
		if not unit: continue
		if unit.hp == 0: continue
		
		var data:UnitData = Constants.unit_data[unit.id]
		if data.type == Constants.UnitType.boss: continue
		match unit.id:
			_:pass
#endregion
#region Ability Mechanics
func evaluate_ability(id:Constants.UnitID) -> Dictionary:
	## check if any units have the id
	## if yes, execute the ability & return any data needed
	return {}
#endregion

#region debug
var debug_unit_id:Constants.UnitID
func debug_spawn() -> void:
	if not Input.is_action_just_pressed("debug_spawn_unit"):
		return
	if not board_has_coord(MouseLogic.board_under_cursor,MouseLogic.coord_under_cursor):
		return
	if unit_at(MouseLogic.coord_under_cursor, MouseLogic.board_under_cursor):
		return
	var unit:Unit = unit_tscn.instantiate()
	boards[MouseLogic.board_under_cursor].add_child(unit)
	unit.id = debug_unit_id
	unit.logical_position = MouseLogic.coord_under_cursor
	update_unit_order_badges()

func debug_delete() -> void:
	if not Input.is_action_just_pressed("debug_delete_unit"):
		return
	if not board_has_coord(MouseLogic.board_under_cursor,MouseLogic.coord_under_cursor):
		return
	if not unit_at(MouseLogic.coord_under_cursor, MouseLogic.board_under_cursor):
		return
	
	var unit:Unit = unit_at(MouseLogic.coord_under_cursor, MouseLogic.board_under_cursor)
	boards[MouseLogic.board_under_cursor].remove_child(unit)
	unit.queue_free()
	
#endregion
