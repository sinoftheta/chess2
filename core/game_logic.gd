extends Node

var unit_tscn:PackedScene = preload("res://unit/unit.tscn")

#region Setup
func _ready() -> void:
	SignalBus.move_unit_to_cursor.connect(_on_move_unit_to_cursor)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.play_button_pressed.connect(_on_play_button_pressed)
	SignalBus.reroll_button_pressed.connect(_on_reroll_button_pressed)

func _on_start_game() -> void:
	animating = false
	for board:Board in boards.values():
		for unit:Unit in board.get_children():
			board.remove_child(unit)
			unit.queue_free()
	
	var unit:Unit = unit_tscn.instantiate()
	play_board.add_child(unit)
	unit.id = Constants.UnitID.test_attacker
	unit.logical_position = Vector2i(0,0)
	
	var unit2:Unit = unit_tscn.instantiate()
	play_board.add_child(unit2)
	unit2.id = Constants.UnitID.test_healer
	unit2.logical_position = Vector2i(1,1)
	
	var unit3:Unit = unit_tscn.instantiate()
	play_board.add_child(unit3)
	unit3.id = Constants.UnitID.test_multiplier
	unit3.logical_position = Vector2i(2,2)
	
	round = 1
	turn = 1
	money = 10
	reroll_price = 5
	SignalBus.game_started.emit()
#endregion

#region Boards
var boards:Dictionary[Constants.BoardID, Board]
var play_board:Board: 
	get(): return boards[Constants.BoardID.play]
var shop_board:Board: 
	get(): return boards[Constants.BoardID.shop]
var sell_board:Board: 
	get(): return boards[Constants.BoardID.sell]
var bonus_board:Board: 
	get(): return boards[Constants.BoardID.bonus]

func board_has_coord(board_id:Constants.BoardID, coord:Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO,boards[board_id].logical_size).has_point(coord)
		
var board_under_cursor:Constants.BoardID
var coord_under_cursor:Vector2i:
	get():
		var cur_board:Board = boards[board_under_cursor]
		var bp:Vector2 = cur_board.global_position - cur_board.get_global_mouse_position() # + cur_board.size * 0.5 if we wanna meke the boards expandable???
		return Vector2i(floori(-bp.x / Constants.GRID_SIZE),floori(-bp.y / Constants.GRID_SIZE))

var prev_board_under_cursor:Constants.BoardID
var prev_coord_under_cursor:Vector2i
func _process(delta: float) -> void:
	if  prev_board_under_cursor != board_under_cursor or\
		prev_coord_under_cursor != coord_under_cursor:
			prev_board_under_cursor = board_under_cursor
			prev_coord_under_cursor = coord_under_cursor
			SignalBus.logical_mouse_location_updated.emit(
				board_under_cursor,
				coord_under_cursor,
				board_has_coord(prev_board_under_cursor,coord_under_cursor)
			)
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
#endregion

#region Run State
var max_rounds:int = 5
var round:int:
	set(value):
		round = value
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
#endregion

#region helpers
func unit_at(coord:Vector2i, board_id:Constants.BoardID) -> Unit:
	return boards[board_id].get_node_or_null(Util.coord_to_name(coord))
#endregion

#region Game logic
func _on_move_unit_to_cursor(unit:Unit) -> void:
	var from_board:Board             = unit.get_parent()
	var from_coord:Vector2i          = unit.logical_position
	var to_board:Board               = boards[board_under_cursor]
	var to_coord:Vector2i            = coord_under_cursor
	var same_boards:bool = to_board != from_board
	
	if animating: return
	
	if not board_has_coord(to_board.id, to_coord):
		## trying to move oob
		return
	
	if unit_at(to_coord,to_board.id):
		## already something there
		return
	
	var gp:Vector2 = unit.global_position
	
	if same_boards:
		
		from_board.remove_child(unit)
		to_board.add_child(unit)
	unit.logical_position = to_coord
	unit.global_position  = gp


func _on_play_button_pressed() -> void:
	if animating:return
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	animating = true
	var animation_tick :int = 0
	var units_evaluated:int = 0
	
	for unit:Unit in play_board.get_children():
		unit.stat = 1.0
	
	## evaluate each tile on the board
	for eval_coord:Vector2i in Util.board_evaluation_order(6):
		var unit:Unit = unit_at(eval_coord, Constants.BoardID.play)
		if not unit: continue
		if unit.hp == 0: continue
		
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
			if not affected_unit: continue
			if unit.hp == 0: continue
			
			match data.type:
				Constants.UnitType.attacker:
					## apply damage
					var prev_hp:float = affected_unit.hp
					affected_unit.hp = maxf(affected_unit.hp - unit.stat, 0.0)
					
					## animate
					affected_unit.animate_attacked(tween, animation_tick, unit.logical_position, prev_hp)
					
					## check for death
					if affected_unit.hp == 0:
						unit_died = true
						affected_unit.animate_dead(tween, animation_tick)
						
				Constants.UnitType.healer:
					pass
				Constants.UnitType.multiplier:
					pass
				Constants.UnitType.boss:
					pass
		if unit_died: animation_tick  += 1
		animation_tick  += 1
		units_evaluated += 1
	
	
	
	tween.tween_callback(func () -> void: 
		animating = false
		## check for dead units and delete them
		for unit:Unit in play_board.get_children():
			if unit.hp == 0:
				play_board.remove_child(unit)
				unit.queue_free()
	).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
func _on_reroll_button_pressed() -> void:
	if animating:return
	
	if money < reroll_price:
		#SignalBus.cant_afford_reroll.emit()
		return
	animating = true
	animating = false


#endregion

#region debug
var debug_unit_id:Constants.UnitID
func debug_spawn() -> void:
	if not Input.is_action_just_pressed("debug_spawn_unit"):
		return
	if not board_has_coord(board_under_cursor,coord_under_cursor):
		return
	if unit_at(coord_under_cursor, board_under_cursor):
		return
	var unit:Unit = unit_tscn.instantiate()
	boards[board_under_cursor].add_child(unit)
	unit.id = debug_unit_id
	unit.logical_position = coord_under_cursor
func debug_delete() -> void:
	if not Input.is_action_just_pressed("debug_delete_unit"):
		return
	if not board_has_coord(board_under_cursor,coord_under_cursor):
		return
	if not unit_at(coord_under_cursor, board_under_cursor):
		return
	
	var unit:Unit = unit_at(coord_under_cursor, board_under_cursor)
	boards[board_under_cursor].remove_child(unit)
	unit.queue_free()
	
#endregion
