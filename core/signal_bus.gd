extends Node


signal start_game()# TODO: pass in game settings
signal game_started()

signal drag_started(object)
signal drag_ended(object, location)

signal move_unit_to_cursor(unit:Unit)

signal menu_updated(menu:Constants.Menu)
