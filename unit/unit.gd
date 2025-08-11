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
var stat:float = 1.0
var hp:float = 10.0
#endregion

#region Cursor interactions
var dragging:bool
var hovered:bool
func cursor_inside() -> bool:
	return Rect2(%Interaction.global_position, %Interaction.size).has_point(get_global_mouse_position())
func _on_interaction_mouse_entered() -> void:
	hovered = true
	SignalBus.tooltip_try_open.emit(self)
func _on_interaction_mouse_exited() -> void:
	if dragging:
		return
	hovered = false
	SignalBus.tooltip_try_close.emit(self)
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

#region tooltip
func tooltip_focus_gained() -> void:
	pass
func tooltip_focus_lost() -> void:
	pass
#endregion

#region Animations
func animate_test(tween:Tween, animation_tick:int, units_evaluated:int) -> void:
	%OrdinalValue.text = Util.int_ordinal_suffix(units_evaluated + 1)
	
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(%OrdinalCard, "modulate:a", 1.0, 0.0)\
	.from(0.0).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	tween.tween_property(%OrdinalCard, "modulate:a", 0.0, 0.0)\
	.from(1.0).set_delay((animation_tick + 1) * Constants.ANIMATION_TICK_TIME)
	
	
	tween.tween_callback(func () -> void: SignalBus.animate_unit_aoe.emit(self))\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
func animate_attacking(tween:Tween, animation_tick:int) -> void:
	pass

func animate_attacked(tween:Tween, animation_tick:int, source_coord:Vector2i) -> void:
	assert(animation_tick > 0)
	
	projectile_animation(tween, animation_tick, source_coord, Constants.UnitType.attacker)
	
	
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	

func animate_multiplying(tween:Tween, animation_tick:int) -> void:
	pass
func animate_multiplied(tween:Tween, animation_tick:int, source_coord:Vector2i) -> void:
	assert(animation_tick > 0)

func animate_healing(animation_tick:int) -> void:
	pass

func animate_healed(tween:Tween, animation_tick:int, source_coord:Vector2i) -> void:
	assert(animation_tick > 0)


func projectile_animation(tween:Tween, animation_tick:int, source_coord:Vector2i, type:Constants.UnitType) -> void:

	tween.tween_callback(func() -> void:
		(%Projectile as Projectile).visible = true
		(%Projectile as Projectile).type = type
	)\
	.set_delay((animation_tick - 1) * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(
		%Projectile, "position", 
		(get_parent() as Board).position + (Vector2(logical_position) + Vector2(0.5,0.5)) * Constants.GRID_SIZE,
			Constants.ANIMATION_TICK_TIME)\
	.from(
		(get_parent() as Board).position + (Vector2(source_coord    ) + Vector2(0.5,0.5)) * Constants.GRID_SIZE
	)\
	.set_delay((animation_tick - 1) * Constants.ANIMATION_TICK_TIME)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_EXPO)
		
	tween.tween_callback(func() -> void:%Projectile.visible = false)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
#func animate_effect(animation_tick:int) -> void:
	#pass
	
#endregion
