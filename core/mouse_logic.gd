extends Node

func _ready() -> void:
	SignalBus.move_unit_to_cursor.connect(_on_move_unit_to_cursor)

func _on_move_unit_to_cursor(unit:Unit) -> void:
	if board_id_under_cursor == Constants.BoardID.none: return
	if not GameLogic.board_has_coord(board_id_under_cursor, coord_under_cursor):return
	
	
	GameLogic.move_unit(unit, board_id_under_cursor, coord_under_cursor)

var prev_board_under_cursor:Constants.BoardID
var prev_coord_under_cursor:Vector2i

var board_id_under_cursor:Constants.BoardID
var coord_under_cursor:Vector2i
