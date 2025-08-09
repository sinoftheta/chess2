extends Node




#region Game inputs
signal start_game()# TODO: pass in game settings
signal play_button_pressed()
signal reroll_button_pressed()
signal move_unit_to_cursor(unit:Unit)
#endregion

#region game outputs
signal money_changed(new:int,prev:int)
signal turn_changed(turns:int)
signal round_changed(round:int)
signal reroll_price_changed(price:int)
signal game_started()
#endregion

#region tooltip
signal tooltip_try_open(unit:Unit)
signal tooltip_try_close(unit:Unit)
signal tooltip_closed()

signal logical_mouse_location_updated(board:Constants.BoardID, coord:Vector2i, in_bounds:bool)
#endregion

#region application
signal menu_updated(menu:Constants.Menu)
#endregion


#region game events
#endregion
