extends Control


func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)
	match OS.get_name():
		"Web":
			%Quit.visible = false
		_:pass
func _on_menu_updated(menu:Constants.Menu, prev:Constants.Menu) -> void:
	visible = menu == Constants.Menu.main


func _on_play_pressed() -> void:
	SignalBus.start_game.emit()
	MenuLogic.push(Constants.Menu.gameplay)

func _on_options_pressed() -> void:
	MenuLogic.push(Constants.Menu.options)


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
