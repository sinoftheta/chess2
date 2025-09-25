extends Node


var cursor_coord:Vector2i
var cursor_board_id:Constants.BoardID = Constants.BoardID.none


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_click"):
		
		## aw hell yeah that sweet sweet debug UX UGH such a good use of my time
		if cursor_coord == MouseLogic.coord_under_cursor and\
			cursor_board_id == MouseLogic.board_id_under_cursor:
			
			cursor_coord = Vector2i.ZERO
			cursor_board_id = Constants.BoardID.none
		else:
			cursor_coord = MouseLogic.coord_under_cursor
			cursor_board_id = MouseLogic.board_id_under_cursor
		SignalBus.debug_update_cursor.emit(cursor_coord, cursor_board_id)
		
