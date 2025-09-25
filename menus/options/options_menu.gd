extends Control

func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)
	match OS.get_name():
		"Web":
			%Fullscreen.visible = false
		_:pass
	(%Fullscreen as CheckBox).set_pressed_no_signal(Options.fullscreen)
	(%Tutorial as CheckBox).set_pressed_no_signal(Options.play_tutorial)
	(%Debug as CheckBox).set_pressed_no_signal(Options.debug)
	
func _on_menu_updated(menu:Constants.Menu, prev:Constants.Menu) -> void:
	visible = menu == Constants.Menu.options



func _on_back_pressed() -> void:
	MenuLogic.pop()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	Options.fullscreen = toggled_on


func _on_tutorial_toggled(toggled_on: bool) -> void:
	Options.play_tutorial = toggled_on


func _on_debug_toggled(toggled_on: bool) -> void:
	Options.debug = toggled_on
