extends Node2D

## the AOE preview has two modes of operation
## one when an animation is animating, and one when not

var focused_unit:Unit
func _ready() -> void:
	SignalBus.tooltip_try_open.connect(_on_tooltip_try_open)
	SignalBus.tooltip_closed.connect(_on_tooltip_closed)
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)
	
	SignalBus.animating_state_updated.connect(_on_animating_state_updated)
	SignalBus.animate_unit_aoe.connect(_on_animate_unit_aoe)
	visible = false

#region standby behavior
func _on_tooltip_try_open(opening_unit:Unit) -> void:
	if GameLogic.animating: return
	#if (opening_unit.get_parent() as Board).id != Constants.BoardID.play:
	#	return
	focused_unit = opening_unit
	visible = true
	
func _on_tooltip_closed() -> void:
	for gen_unit:Unit in GameLogic.play_board.get_children():
		gen_unit.target = false

	if GameLogic.animating: return
	focused_unit = null
	visible = false
	


func _on_logical_mouse_position_updated(board_id:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	if GameLogic.animating: return
	if not focused_unit: return
	show_aoe(focused_unit, board_id, coord, true)

#endregion

#region animating behavior
func _on_animating_state_updated(animating:bool) -> void:
	if not animating:
		visible = false

func _on_animate_unit_aoe(unit:Unit) -> void:
	assert(GameLogic.animating)
	visible = true
	show_aoe(unit, (unit.get_parent() as Board).id, unit.logical_position, false)
#endregion

func show_aoe(unit:Unit, board_id:Constants.BoardID, coord:Vector2i, highlight_targets:bool) -> void:
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
	
	for gen_unit:Unit in GameLogic.play_board.get_children():
		gen_unit.target = false
	
	for tile:ColorRect in get_children():
		if i < aoe.size():
			if Rect2i(Vector2i.ZERO, board_node.logical_size).has_point(aoe[i] + offset):
				tile.visible = true
				#tile.position = Vector2(aoe[i] + offset) * Constants.GRID_SIZE
				
				var targeted_unit:Unit = GameLogic.unit_at(aoe[i] + offset, Constants.BoardID.play)
				if targeted_unit:
					targeted_unit.target = true and highlight_targets
			else:
				tile.visible = false
		else:
			tile.visible = false
		i += 1
		
	unit.target = false
