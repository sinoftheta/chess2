extends Node

var prev_board_under_cursor:Constants.BoardID
var prev_coord_under_cursor:Vector2i

var board_id_under_cursor:Constants.BoardID
var coord_under_cursor:Vector2i

var dragged_unit:Unit:
	set(value):
		dragged_unit = value
		if value:
			SignalBus.tooltip_open.emit(value)
		else:
			SignalBus.tooltip_close.emit()

func _ready() -> void:
	SignalBus.move_unit_to_cursor.connect(_on_move_unit_to_cursor)
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_location_updated)

## hide and show the tooltip + aoe preview
func _on_logical_mouse_location_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	var hovered_unit:Unit = GameLogic.unit_at(coord, board)
	
	##TODO
	## Dynamic Unit Move Order Update Logic
	
	## TODO
	## "Drop to purchase!", "Drop to sell!" messages. Maybe thats excessive? idk, thats pretty far off polish
	## detect to and from boards
	
	## Tooltip Visibility Logic
	if dragged_unit:
		## tooltip should already be open
		pass
	elif GameLogic.unit_at(coord, board):
		SignalBus.tooltip_open.emit(hovered_unit)
	else:
		SignalBus.tooltip_close.emit()
		
	## AoE Preview Visibility Logic
	if not dragged_unit and not hovered_unit:
		SignalBus.hide_aoe_preview.emit()
	
	elif board != Constants.BoardID.play or not in_bounds:
		SignalBus.hide_aoe_preview.emit()
		
	elif dragged_unit:
		SignalBus.show_aoe_preview.emit(dragged_unit, coord)
	
	elif hovered_unit:
		SignalBus.show_aoe_preview.emit(hovered_unit, coord)

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

## this really could just go in GameLogic, idk
func _on_move_unit_to_cursor(unit:Unit) -> void:
	if board_id_under_cursor == Constants.BoardID.none: return
	if not GameLogic.board_has_coord(board_id_under_cursor, coord_under_cursor):return
	
	GameLogic.move_unit(unit, board_id_under_cursor, coord_under_cursor)
