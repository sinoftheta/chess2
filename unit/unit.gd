class_name Unit
extends Node2D

#region Game logic
var id:Constants.UnitID:
	set(value):
		id = value
		var data:UnitData = Constants.unit_data[value]
		%Sprite.texture = data.texture
var logical_position:Vector2i:
	set(value):
		logical_position = value
		name = Util.coord_to_name(logical_position)
		#z_index = value.y
var stat:int
var hp:int
#endregion

#region Cursor interactions
var dragging:bool
var hovered:bool
func cursor_inside() -> bool:
	return Rect2(%Interaction.global_position, %Interaction.size).has_point(get_global_mouse_position())
func _on_interaction_mouse_entered() -> void:
	hovered = true
func _on_interaction_mouse_exited() -> void:
	if dragging:
		return
	hovered = false
func _on_interaction_button_down() -> void:
	hovered = true
	dragging = true
	#z_index = 2
func _on_interaction_button_up() -> void:
	dragging = false
	#z_index = 0
	SignalBus.move_unit_to_cursor.emit(self)
	hovered = cursor_inside()

#var prev_mouse_x:float
func _process(delta: float) -> void:
	var t:float = minf(delta * 13.0,1.0)
	if dragging:
		global_position = lerp(global_position, get_global_mouse_position(), t)
	else:
		
		var fp:Vector2 = (Vector2(logical_position) + Vector2(0.5,0.5)) * Constants.GRID_SIZE
		var dp:float = delta * 400
		
		position = lerp(position, fp, t)
		
		#if (fp - position).length_squared() < dp:
			#position = fp
		#else:
			#position += (fp - position).normalized() * dp
	

#endregion

#region Animations
#endregion
