extends Node

var unit_tscn:PackedScene = preload("res://unit/unit.tscn")

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

var board_under_cursor:Constants.BoardID
func coord_under_cursor() -> Vector2i:
	var cur_board:Board = boards[board_under_cursor]
	var bp:Vector2 = cur_board.global_position - cur_board.get_global_mouse_position() # + cur_board.size * 0.5 if we wanna meke the boards expandable???
	return Vector2i(floori(-bp.x / Constants.GRID_SIZE),floori(-bp.y / Constants.GRID_SIZE))
	
func unit_at(coord:Vector2i, board_id:Constants.BoardID) -> Unit:
	return boards[board_id].get_node_or_null(Util.coord_to_name(coord))

func _on_move_unit_to_cursor(unit:Unit) -> void:
	var from_board:Board             = unit.get_parent()
	var from_coord:Vector2i          = unit.logical_position
	var to_board:Board               = boards[board_under_cursor]
	var to_coord:Vector2i            = coord_under_cursor()
	var same_boards:bool = to_board != from_board
	
	if not Rect2i(Vector2i.ZERO, to_board.logical_size).has_point(to_coord):
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



var executing:bool

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
	
	SignalBus.game_started.emit()
	
	
	
	
func execute_shop_reroll() -> void:
	executing = true
	executing = false

func execute_turn() -> void:
	executing = true
	executing = false


## USE Node.get_node(coord) to reach units by their coord
