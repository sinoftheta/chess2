class_name Unit
extends Node2D

#region Game logic
var id:Constants.UnitID
var logical_position:Vector2i:
	set(value):
		logical_position = value
		name = Util.coord_to_name(logical_position)
var stat:int
var hp:int
#endregion

#region Hover logic
var hovered:bool:
	set = set_hovered
func _on_mouse_entered() -> void:
	hovered = true
func _on_mouse_exited() -> void:
	hovered = false
	
var hover_tween:Tween
func set_hovered(value:bool) -> void:
	hovered = value
	hover_tween
#endregion

#region Drag logic
var dragged:bool
#endregion

#region Animations
#endregion
