extends Control

var unit:Unit

func _ready() -> void:
	SignalBus.tooltip_try_open.connect(_on_tooltip_try_open)
	SignalBus.tooltip_try_close.connect(_on_tooltip_try_close)
	visible = false

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
func tooltip_closed() -> void:
	visible = false
