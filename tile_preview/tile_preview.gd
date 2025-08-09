extends Node2D

var unit:Unit
func _ready() -> void:
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	visible = in_bounds
	position = GameLogic.boards[board].position + (Vector2(coord) + Vector2(0.5,0.5)) * Constants.GRID_SIZE
	
