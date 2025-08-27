extends HBoxContainer


#Debug.spawn_obj_id
#Debug.spawn_additional_abilities

func _ready() -> void:
	for id:Constants.UnitID in Constants.UnitID.values():
		(%UnitID as OptionButton).add_item(Constants.UnitID.keys()[id], id)
		# could use add_icon_item here actually
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	pass
	#visible = not in_bounds


func _on_unit_id_item_selected(index: int) -> void:
	GameLogic.debug_unit_id = index


func _on_add_20_money_pressed() -> void:
	GameLogic.money += 20 

func _on_reset_money_pressed() -> void:
	GameLogic.money = 0

func _on_weaken_boss_pressed() -> void:
	for unit:Unit in GameLogic.play_board.get_children():
		if Constants.unit_data[unit.id].type == Constants.UnitType.boss:
			unit.hp = 1
