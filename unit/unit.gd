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

#region Cursor interactions
enum CursorState{
	none,
	hovering,
	draging,
	returning,
}
var hovered:bool:
	set = set_hovered
var dragged:bool
func _on_mouse_entered() -> void:
	hovered = true
func _on_mouse_exited() -> void:
	hovered = false
	
var hover_tween:Tween
func set_hovered(value:bool) -> void:
	hovered = value
	hover_tween



var prev_mouse_x:float
func _process(delta: float) -> void:
	var r_target:float
	var s_target:Vector2
	
	if dragged:
		r_target = -clamp((get_global_mouse_position().x - prev_mouse_x) * 0.1, -PI * 0.4, PI*0.4)
		s_target = Vector2(1.25,1.25)

		## when we're being dragged, we aren't being reparented
		## with position smoothing
		global_position = lerp(global_position, get_global_mouse_position(),minf(delta * 13, 1.0))
		
		prev_mouse_x =  get_global_mouse_position().x
	else:
		s_target = Vector2.ONE
		r_target = 0
	#%PickupTX.scale    = lerp(%PickupTX.scale,    s_target, minf(delta * 13, 1.0))
	#%PickupTX.rotation = lerp(%PickupTX.rotation, r_target, minf(delta * 7, 1.0))

#endregion

#region Animations
#endregion
