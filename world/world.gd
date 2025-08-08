extends Node2D

func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)

func _on_menu_updated(menu:Constants.Menu) -> void:
	visible = menu == Constants.Menu.gameplay
