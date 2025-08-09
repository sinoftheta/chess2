extends Node

var unit_tscn:PackedScene = preload("res://unit/unit.tscn")

#region Setup
func _ready() -> void:
	SignalBus.move_unit_to_cursor.connect(_on_move_unit_to_cursor)
	SignalBus.start_game.connect(_on_start_game)

func _on_start_game() -> void:
	executing = false
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
			
#endregion

#region Animation
var executing:bool
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
	unit.global_position = gp

func execute_shop_reroll() -> void:
	executing = true
	executing = false

func execute_turn() -> void:
	executing = true
	executing = false

#endregion
