class_name Unit
extends Node2D



func _ready() -> void:
	SignalBus.animating_state_updated.connect(_on_animation_state_updated)
#region target preview
var target:bool:
	set(value):
		%TargetedIndicator.visible = value
var play_order:int:
	set(value):
		play_order = value
		%OrderValue.visible = value > 0
		%OrderValue.text = str(value)
#endregion

func _on_animation_state_updated(animating:bool) -> void:
	stat = init_stat
#region Game logic
var id:Constants.UnitID:
	set(value):
		id = value
		var data:UnitData = Constants.unit_data[value]
		%Sprite.texture = data.texture
		max_hp = data.base_health
		hp = data.base_health
		init_stat = data.base_stat
		stat = data.base_stat
var logical_position:Vector2i:
	set(value):
		logical_position = value
		name = Util.coord_to_name(logical_position)
		#%MovedInidicator.visible = logical_position != prev_logical_position
		#z_index = value.y
var prev_logical_position:Vector2i:
	set(value):
		prev_logical_position = value
		#%MovedInidicator.visible = logical_position != prev_logical_position

var turns_in_play:int = 0
var init_stat:float = 1.0
var stat:float = 1.0
var hp:float = 10.0
var max_hp:float = 10.0
var dead:bool = false

var buy_price:int:
	get():
		return Constants.unit_data[id].base_shop_price
var sell_price:int:
	get():
		return maxi(Constants.unit_data[id].base_shop_price >> 1, 1)
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
func animate_type_effect(tween:Tween, animation_tick:int, units_evaluated:int) -> void:
	
	match Constants.unit_data[id].type:
		Constants.UnitType.attacker:
			message_animation(tween, animation_tick, "ATCK: " + str(stat) + "!")
		Constants.UnitType.healer:
			message_animation(tween, animation_tick, "HEAL: " + str(stat) + "!")
		Constants.UnitType.multiplier:
			message_animation(tween, animation_tick, "MULT: " + str(stat) + "!")
		Constants.UnitType.boss:
			pass
	
	## move order indicator
	
	#tween.tween_callback(func () -> void: 
		#%OrderValue.text = Util.int_ordinal_suffix(units_evaluated + 1)
		#%OrderBadge.visible = true
	#).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	#
	#tween.tween_callback(func () -> void: 
		#%OrderBadge.visible = false
	#).set_delay((animation_tick + 1) * Constants.ANIMATION_TICK_TIME)
	#
	## show the units AoE
	tween.tween_callback(func () -> void: SignalBus.animate_unit_aoe.emit(self))\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	## make the unit bounce
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	

func animate_attacked(tween:Tween, animation_tick:int, source_coord:Vector2i, prev_hp:float) -> void:
	assert(animation_tick > 0)
	
	projectile_animation(tween, animation_tick, source_coord, Constants.UnitType.attacker)
	
	message_animation(tween, animation_tick, "-" + str(prev_hp - hp) + "!")
	
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_callback(func() -> void:%HPBar.visible = true)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(%HPBar, "size:x", hp_bar_length(hp), Constants.ANIMATION_TICK_TIME * 0.25)\
	.from(hp_bar_length(prev_hp))\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_callback(func() -> void:%HPBar.visible = false)\
	.set_delay((animation_tick + 1) * Constants.ANIMATION_TICK_TIME)
	
	

func animate_multiplied(tween:Tween, animation_tick:int, source_coord:Vector2i, factor:float) -> void:
	assert(animation_tick > 0)
	projectile_animation(tween, animation_tick, source_coord, Constants.UnitType.multiplier)
	message_animation(tween, animation_tick, "x" + str(factor) + "!")

	## the bounce
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)

func animate_added(tween:Tween, animation_tick:int, source_coord:Vector2i, addend:float) -> void:
	assert(animation_tick > 0)
	projectile_animation(tween, animation_tick, source_coord, Constants.UnitType.adder)
	message_animation(tween, animation_tick, "+" + str(addend) + "!")

	## the bounce
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	

func animate_healed(tween:Tween, animation_tick:int, source_coord:Vector2i, prev_hp:float) -> void:
	assert(animation_tick > 0)
	
	projectile_animation(tween, animation_tick, source_coord, Constants.UnitType.healer)
	
	message_animation(tween, animation_tick, "+" + str(hp - prev_hp) + "!")
	
	## the bounce
	tween.tween_property(%Sprite, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME * 0.75)\
	.from(Vector2(0.5,2.0))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_callback(func() -> void:%HPBar.visible = true)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(%HPBar, "size:x", hp_bar_length(hp), Constants.ANIMATION_TICK_TIME * 0.25)\
	.from(hp_bar_length(prev_hp))\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_callback(func() -> void:%HPBar.visible = false)\
	.set_delay((animation_tick + 1) * Constants.ANIMATION_TICK_TIME)

func animate_dead(tween:Tween, animation_tick:int) -> void:
	message_animation(tween, animation_tick, "DIED!")
	%Interaction
	tween.tween_callback(func() -> void:
		%Sprite.visible = false
		%Interaction.visible = false
		%OrderValue.visible = false
		hovered = false
		dragging = false
		SignalBus.tooltip_try_close.emit(self)
		%DeadParticles.emitting = true
	).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)

func animate_spawn(tween:Tween, animation_tick:int) -> void:
	%Sprite.visible = false
	%Interaction.visible = false
	tween.tween_callback(func() -> void:
		%Sprite.visible = true
		%Interaction.visible = true
		%DeadParticles.emitting = true
	).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)

## animation helpers
func message_animation(tween:Tween, animation_tick:int, message:String) -> void:
	tween.tween_callback(func() -> void:
		%Message.visible = true
		%Message.text = message
	).set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(%Message, "rotation", 0.0, Constants.ANIMATION_TICK_TIME)\
	.from(randf_range(-0.2,0.2))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_property(%Message, "scale", Vector2.ONE, Constants.ANIMATION_TICK_TIME)\
	.from(Vector2(randf_range(1.75,2.0), randf_range(0.45,0.55)))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
	
	tween.tween_callback(func() -> void:
		%Message.visible = false
	).set_delay((animation_tick + 1) * Constants.ANIMATION_TICK_TIME)
	
func hp_bar_length(given_hp:float) -> float:
	return given_hp/max_hp * 50.0
	
func projectile_animation(tween:Tween, animation_tick:int, source_coord:Vector2i, type:Constants.UnitType) -> void:

	tween.tween_callback(func() -> void:
		### TODO: we gotta only change the visibility of the core, this should go in Projectile
		(%Projectile as Projectile).visible = true
		(%Projectile as Projectile).restart()
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
	.set_trans(Tween.TRANS_CUBIC)
		
	tween.tween_callback(func() -> void:%Projectile.visible = false)\
	.set_delay(animation_tick * Constants.ANIMATION_TICK_TIME)
#func animate_effect(animation_tick:int) -> void:
	#pass
	
#endregion
