extends Control


func _ready() -> void:
	for id:Constants.UnitID in Constants.UnitID.values():
		(%UnitID as OptionButton).add_item(Constants.UnitID.keys()[id], id)
		# could use add_icon_item here actually
	SignalBus.logical_mouse_location_updated.connect(_on_logical_mouse_position_updated)

func _on_logical_mouse_position_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool) -> void:
	visible = not in_bounds and MenuLogic.current() == Constants.Menu.gameplay and Options.debug

func _on_unit_id_item_selected(index: int) -> void:
	## for when the day comes that I move all this shite logic
	## to Debug for some reason
	#Debug.unit_id = index
	pass


func _on_add_20_money_pressed() -> void:
	GameLogic.money += 20 

func _on_reset_money_pressed() -> void:
	GameLogic.money = 0

func _on_weaken_boss_pressed() -> void:
	for unit:Unit in GameLogic.play_board.get_children():
		if Constants.unit_data[unit.id].type == Constants.UnitType.boss:
			unit.hp = 1
			unit.animated_hp = unit.hp
			

func debug_unit() -> Unit:
	return GameLogic.unit_at(
		Debug.cursor_coord,
		Debug.cursor_board_id
	)

func _on_spawn_unit_pressed() -> void:
	if debug_unit(): return

	var unit:Unit = GameLogic.unit_tscn.instantiate()
	(GameLogic.boards[Debug.cursor_board_id] as Board).add_child(unit)
	
	unit.id = (%UnitID as OptionButton).get_item_id((%UnitID as OptionButton).selected)
	unit.logical_position = Debug.cursor_coord
	
	GameLogic.update_unit_order_badges()

func _on_remove_unit_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return
	
	unit.get_parent().remove_child(unit)
	unit.queue_free()
	GameLogic.update_unit_order_badges()

func _on_weaken_unit_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return
	
	unit.hp = 1
	unit.animated_hp = unit.hp

func _on_sub_hp_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return

	unit.hp = maxi(unit.hp - 1, 1)
	unit.animated_hp = unit.hp

func _on_add_hp_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return

	unit.hp = unit.hp + 1
	unit.animated_hp = unit.hp



func _on_add_base_stat_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return

	unit.init_stat = unit.init_stat + 1


func _on_sub_base_stat_pressed() -> void:
	var unit:Unit = debug_unit()
	if not unit: return

	unit.init_stat = maxi(unit.init_stat - 1, 0)
