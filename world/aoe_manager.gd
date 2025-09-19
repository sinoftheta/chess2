extends Node

## the AOE preview has two modes of operation
## one when an animation is animating, and one when not

func _ready() -> void:
	SignalBus.show_aoe_preview.connect(_on_show_aoe_preview)
	SignalBus.hide_aoe_preview.connect(_on_hide_aoe_preview)

	
	SignalBus.animating_state_updated.connect(_on_animating_state_updated)
	SignalBus.animate_unit_aoe.connect(_on_animate_unit_aoe)


func _on_show_aoe_preview(unit:Unit, at_coords:Vector2i) -> void:
	_on_hide_aoe_preview()
	
	
	print("_on_show_aoe_preview")
	
	var data:UnitData = Constants.unit_data[unit.id]
	var aoe:Array[Vector2i] = data.aoe
	var offset:Vector2i
	
	if data.aoe_is_absolute:
		offset = Vector2i.ZERO
	else:
		offset = at_coords
	
	for aoe_coord:Vector2i in aoe:
		var tile:Tile = GameLogic.play_tile_manager.get_node_or_null(
			Util.coord_to_name(aoe_coord + offset)
		)
		if not tile: continue
		
		## TODO: change tile highlight color here based on the units type
		tile.aoe_highlight = true
		match data.type:
			Constants.UnitType.attacker:
				tile.aoe_highlight_color = Color("f6a250")
			Constants.UnitType.healer:
				tile.aoe_highlight_color = Color("54cdf9")
			Constants.UnitType.multiplier:
				tile.aoe_highlight_color = Color("d95763")
			Constants.UnitType.adder:
				tile.aoe_highlight_color = Color("aff070")
			Constants.UnitType.boss:
				tile.aoe_highlight_color = Color("8a5398")
			_:
				tile.aoe_highlight_color = Color.WHITE
		
		
		var local_unit:Unit = GameLogic.unit_at(aoe_coord + offset, Constants.BoardID.play)
		
		if not local_unit or unit == local_unit: continue
		
		local_unit.target = true


	
	
func _on_hide_aoe_preview() -> void:
	for tile:Tile in GameLogic.play_tile_manager.get_children():
		tile.aoe_highlight = false
	for gen_unit:Unit in GameLogic.play_board.get_children():
		gen_unit.target = false



#region animating behavior
func _on_animating_state_updated(animating:bool) -> void:
	pass

func _on_animate_unit_aoe(unit:Unit) -> void:
	assert(GameLogic.animating)
	#show_aoe(unit, (unit.get_parent() as Board).id, unit.logical_position, false)
#endregion
