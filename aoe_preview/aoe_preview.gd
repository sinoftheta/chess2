extends Node2D

var unit:Unit
func _ready() -> void:
	SignalBus.tooltip_try_open.connect(_on_tooltip_try_open)
	SignalBus.tooltip_closed.connect(_on_tooltip_closed)
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)
	
func _on_tooltip_try_open(focused_unit:Unit) -> void:
	unit = focused_unit

func _on_tooltip_closed() -> void:
	unit = null

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	print("board: ", board, " coord: ", coord, " in_bounds: ", in_bounds)
	
