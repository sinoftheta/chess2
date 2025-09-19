extends Node

var prev_board_under_cursor:Constants.BoardID
var prev_coord_under_cursor:Vector2i

var board_id_under_cursor:Constants.BoardID
var coord_under_cursor:Vector2i

var dragged_unit:Unit
func _ready() -> void:
	SignalBus.move_unit_to_cursor.connect(_on_move_unit_to_cursor)


func _process(delta: float) -> void:
	var cursor_over_board:bool = false
	for board:Board in GameLogic.boards.values():
		if not board.texture: continue
		if Rect2(board.global_position,board.global_scale * board.texture.get_size())\
		.has_point(board.get_global_mouse_position()):

			var local:Vector2 = board.to_local(board.get_global_mouse_position())

			local.x /= board.global_scale.x * board.texture.get_size().x
			local.y /= board.global_scale.y * board.texture.get_size().y
			
			board_id_under_cursor = board.id
			coord_under_cursor = Vector2i(
				int(local.x * board.logical_size.x),
				int(local.y * board.logical_size.y)
			)
			cursor_over_board = true
			break
	if not cursor_over_board:
		board_id_under_cursor = Constants.BoardID.none
		coord_under_cursor = Vector2.ZERO
		
	if (prev_board_under_cursor != board_id_under_cursor or
		prev_coord_under_cursor != coord_under_cursor):
			SignalBus.logical_mouse_location_updated.emit(
				board_id_under_cursor,
				coord_under_cursor,
				cursor_over_board
			)
			prev_board_under_cursor = board_id_under_cursor
			prev_coord_under_cursor = coord_under_cursor
	#print(coord_under_cursor, " on ", Constants.BoardID.keys()[board_id_under_cursor])

func _on_move_unit_to_cursor(unit:Unit) -> void:
	if board_id_under_cursor == Constants.BoardID.none: return
	if not GameLogic.board_has_coord(board_id_under_cursor, coord_under_cursor):return
	
	
	GameLogic.move_unit(unit, board_id_under_cursor, coord_under_cursor)
