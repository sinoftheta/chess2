extends HBoxContainer


#Debug.spawn_obj_id
#Debug.spawn_additional_abilities

func _ready() -> void:
	for id:Constants.UnitID in Constants.UnitID.values():
		(%UnitID as OptionButton).add_item(Constants.UnitID.keys()[id], id)
		# could use add_icon_item here actually
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	visible = not in_bounds


func _on_unit_id_item_selected(index: int) -> void:
	GameLogic.debug_unit_id = index
