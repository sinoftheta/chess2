## MenuLogic
extends Node

var stack:Array[Constants.Menu] = [Constants.Menu.none]

func pop() -> void:
	if stack.back() == Constants.Menu.none:
		return
	stack.pop_back()
	SignalBus.menu_updated.emit(stack.back())
	
func push(menu:Constants.Menu) -> void:
	if stack.back() == menu:
		return
	stack.push_back(menu)
	SignalBus.menu_updated.emit(stack.back())
