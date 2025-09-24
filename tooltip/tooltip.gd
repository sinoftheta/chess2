class_name Tooltip
extends Control

var unit:Unit

func _ready() -> void:
	SignalBus.tooltip_open.connect(_on_tooltip_open)
	SignalBus.tooltip_close.connect(_on_tooltip_close)
	SignalBus.unit_moved.connect(_on_unit_moved)
	(%UnitPreview as Sprite2D).hframes = (%UnitPreview as Sprite2D).texture.get_width()  / 48
	(%UnitPreview as Sprite2D).vframes = (%UnitPreview as Sprite2D).texture.get_height() / 48
	tooltip_closed()

func _on_unit_moved(moved_unit:Unit, prev_coord:Vector2i, prev_board:Board) -> void:
	if moved_unit == unit:
		#print("ayo update the thing")
		pass
func _on_tooltip_open(opened_unit:Unit) -> void:
	#if unit:
		#unit.tooltip_focus_lost()
	unit = opened_unit
	#unit.tooltip_focus_gained()
	tooltip_opened()
	
	
func _on_tooltip_close() -> void:
	tooltip_closed()

func tooltip_opened() -> void:
	
	## TODO: show boss level ?
	
	var data:UnitData = Constants.unit_data[unit.id]
	var is_boss:bool = data.type == Constants.UnitType.boss
	match (unit.get_parent() as Board).id:
		Constants.BoardID.play:
			%BuySellTooltip.visible = not is_boss
			%BuySellText.text = "SELL"
			%BuySellValue.text = "$" + str(unit.sell_price)
			
			%OrderText       .visible = true
			%OrderContentBack.visible = true
			%OrderValueBack  .visible = true
			%Order           .visible = true
		#Constants.BoardID.shop:
			#%BuySellTooltip.visible = true
			#%BuySellText.text = "BUY"
			#%BuySellValue.text = "$" + str(unit.buy_price)
			#
			#%OrderText       .visible = false
			#%OrderContentBack.visible = false
			#%OrderValueBack  .visible = false
			#%Order           .visible = false
		#Constants.BoardID.bonus:
			#%BuySellTooltip.visible = false
		_:
			print("TOOLTIP NOT IMPLEMENTED FOR UNITS ON THE ", Constants.BoardID.keys()[(unit.get_parent() as Board).id], " BOARD")
			return
	%StatsTooltip.visible   = true
	%AbilityTooltip.visible = data.description.length() > 0
	%AoePreview.queue_redraw()
	
	
	
	%AbilityText.text = data.description
	(%UnitPreview as Sprite2D).frame_coords = data.texture_coord
	%Title.text = data.title
	#%Rarity.visible = not is_boss
	#%Rarity.text = Constants.ShopRarity.keys()[data.shop_rarity]
	%Order.text = Util.int_ordinal_suffix(unit.play_order)
	%Type.text = Constants.UnitType.keys()[data.type]
	%TypeDescription.text = Constants.type_descriptions[data.type]
	%Stat.text = str(unit.init_stat)
	%HP.text = str(unit.hp)

	
func tooltip_closed() -> void:
	%BuySellTooltip.visible = false
	%StatsTooltip.visible   = false
	%AbilityTooltip.visible = false
	%AoePreview.queue_redraw()
	
