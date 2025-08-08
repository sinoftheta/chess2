class_name Board
extends ColorRect

@export var id:Constants.BoardID
@export var logical_size:Vector2i
func _ready() -> void:
	GameLogic.boards[id] = self
	size = Vector2(logical_size) * Constants.GRID_SIZE
	position -= size * 0.5
	



func _on_mouse_entered() -> void:
	## update a global cur_board_id
	GameLogic.board_under_cursor = id
	#print("mouse in board: ", Constants.BoardID.keys()[id])
