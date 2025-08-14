extends Control

var unit:Unit

func _ready() -> void:
	SignalBus.tooltip_try_open.connect(_on_tooltip_try_open)
	SignalBus.tooltip_try_close.connect(_on_tooltip_try_close)
	SignalBus.unit_moved.connect(_on_unit_moved)
	visible = false

func _on_unit_moved(moved_unit:Unit, prev_coord:Vector2i, prev_board:Board) -> void:
	if moved_unit == unit:
		#print("ayo update the thing")
		pass
func _on_tooltip_try_open(opened_unit:Unit) -> void:
	if unit:
		unit.tooltip_focus_lost()
	unit = opened_unit
	unit.tooltip_focus_gained()
	tooltip_opened()
	
	
func _on_tooltip_try_close(closed_unit:Unit) -> void:
	closed_unit.tooltip_focus_lost()
	if unit != closed_unit: return
	if unit:
		unit.tooltip_focus_lost()
	unit = null
	SignalBus.tooltip_closed.emit()
	tooltip_closed()

func tooltip_opened() -> void:
	visible = true
	var data:UnitData = Constants.unit_data[unit.id]
	var is_boss:bool = data.type == Constants.UnitType.boss
	%Title.text = data.title
	
	%Rarity.visible = not is_boss
	%Rarity.text = Constants.ShopRarity.keys()[data.shop_rarity]
	
	%Type.text = "Type: " + Constants.UnitType.keys()[data.type]
	%TypeDescription.text = Constants.type_descriptions[data.type]
	%Stat.text = "Stat: " + str(unit.stat)
	%HP.text = "HP: " + str(unit.hp) + "/" + str(unit.max_hp)
	
	%SellValue.visible = not is_boss
	%SellValue.text = "Sell Value: $" + str(maxf(floorf(data.base_shop_price * 0.5),1.0))
	
	%SpecialAbility.visible = data.description.length() > 0
	%SpecialAbility.text    = data.description
	
func tooltip_closed() -> void:
	visible = false
