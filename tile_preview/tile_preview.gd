extends ColorRect

var unit:Unit
func _ready() -> void:
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	visible = in_bounds
	position = GameLogic.boards[board].position + Vector2(coord) * Constants.GRID_SIZE
