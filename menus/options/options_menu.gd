extends Control

func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)
	match OS.get_name():
		"Web":
			%Fullscreen.visible = false
		_:pass
	%Fullscreen.set_pressed_no_signal(Options.fullscreen)
	
func _on_menu_updated(menu:Constants.Menu) -> void:
	visible = menu == Constants.Menu.options



func _on_back_pressed() -> void:
	MenuLogic.pop()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	Options.fullscreen = toggled_on
