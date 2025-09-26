extends Node

## the AOE preview has two modes of operation
## one when an animation is animating, and one when not
const PLAY_CENTER:Vector2i = Vector2i(2,2)

func _ready() -> void:
	SignalBus.show_aoe_preview.connect(_on_show_aoe_preview)
	SignalBus.hide_aoe_preview.connect(_on_hide_aoe_preview)

	
	SignalBus.animating_state_updated.connect(_on_animating_state_updated)
	SignalBus.animate_unit_aoe.connect(_on_animate_unit_aoe)

	(%AoEShopHologram as Sprite2D).hframes =\
	(%AoEShopHologram as Sprite2D).texture.get_width()  / 48
	(%AoEShopHologram as Sprite2D).vframes =\
	(%AoEShopHologram as Sprite2D).texture.get_height() / 48



func _process(delta: float) -> void:
	var center_tile:Tile = %PlayTileManager.get_node_or_null(Util.coord_to_name(PLAY_CENTER))
	if center_tile:
		(%AoEShopHologram as Sprite2D).global_position = center_tile.visual_position + Vector2(0.0, -6 + 3 * sin(
			Engine.get_frames_drawn() * 0.02
		))
	var center_unit:Unit = GameLogic.unit_at(PLAY_CENTER, Constants.BoardID.play)
	if center_unit:
		if (%AoEShopHologram as Sprite2D).visible:
			center_unit.modulate = Color(.45,.45,.45)
		else:
			center_unit.modulate = Color.WHITE

func _on_show_aoe_preview(unit:Unit, at_coords:Vector2i, shop_preview:bool) -> void:
	_on_hide_aoe_preview()
	
	(%AoEShopHologram as Sprite2D).visible = shop_preview
	(%AoEShopHologram as Sprite2D).frame_coords = unit.data.texture_coord
	
	var data:UnitData = Constants.unit_data[unit.id]
	var aoe:Array[Vector2i] = data.aoe
	var offset:Vector2i
	
	if data.aoe_is_absolute:
		offset = Vector2i.ZERO
	else:
		offset = at_coords
		
	if shop_preview:
		## show that shit in the middle of the play board
		offset = PLAY_CENTER
	
	for aoe_coord:Vector2i in aoe:
		var tile:Tile = GameLogic.play_tile_manager.get_node_or_null(
			Util.coord_to_name(aoe_coord + offset)
		)
		if not tile: continue
		
		## TODO: OMG please don't have these be hardcoded lmao
		tile.aoe_highlight = true
		var aoe_highlight_color:Color
		match data.type:
			Constants.UnitType.attacker:
				aoe_highlight_color = Color("f6be50")
			Constants.UnitType.healer:
				aoe_highlight_color = Color("d95763")
			Constants.UnitType.multiplier:
				aoe_highlight_color = Color("63d5fe")
			Constants.UnitType.adder:
				aoe_highlight_color = Color("aff070")
			Constants.UnitType.boss:
				aoe_highlight_color = Color("8a5398")
			_:
				aoe_highlight_color = Color.WHITE
		
		if shop_preview:
			## the preview is always white or whatever
			aoe_highlight_color = Color.WHITE
		
		tile.aoe_highlight_color = aoe_highlight_color
		
		
		var local_unit:Unit = GameLogic.unit_at(aoe_coord + offset, Constants.BoardID.play)
		
		if not local_unit or unit == local_unit: continue
		
		local_unit.target = not shop_preview
		local_unit.target_color = aoe_highlight_color


	
	
func _on_hide_aoe_preview() -> void:
	for tile:Tile in GameLogic.play_tile_manager.get_children():
		tile.aoe_highlight = false
	for gen_unit:Unit in GameLogic.play_board.get_children():
		gen_unit.target = false
	%AoEShopHologram.visible = false



#region animating behavior
func _on_animating_state_updated(animating:bool) -> void:
	pass

func _on_animate_unit_aoe(unit:Unit) -> void:
	assert(GameLogic.animating)
	#show_aoe(unit, (unit.get_parent() as Board).id, unit.logical_position, false)
#endregion
