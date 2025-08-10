extends Node2D

var unit:Unit
func _ready() -> void:
	SignalBus.tooltip_try_open.connect(_on_tooltip_try_open)
	SignalBus.tooltip_closed.connect(_on_tooltip_closed)
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)
	visible = false

func _on_tooltip_try_open(focused_unit:Unit) -> void:
	unit = focused_unit
	visible = true
	

func _on_tooltip_closed() -> void:
	unit = null
	visible = false

func _on_logical_mouse_position_updated(board_id:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	if not unit:
		return
	#print("board: ", board, " coord: ", coord, " in_bounds: ", in_bounds)
	var board_node:Board = GameLogic.boards[board_id]
	position = board_node.position
	
	
	var data:UnitData = Constants.unit_data[unit.id]
	var aoe:Array[Vector2i] = data.aoe
	var offset:Vector2i
	
	if data.aoe_is_absolute:
		offset = Vector2i.ZERO
	else:
		offset = coord
	
	var i:int = 0
	
	for tile:ColorRect in get_children():
		if i < aoe.size():
			if Rect2i(Vector2i.ZERO, board_node.logical_size).has_point(aoe[i] + offset):
				tile.visible = true
				tile.position = Vector2(aoe[i] + offset) * Constants.GRID_SIZE
			else:
				tile.visible = false
		else:
			tile.visible = false
		i += 1
		
	
