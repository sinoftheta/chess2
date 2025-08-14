extends Label

var tween:Tween
func _ready() -> void:
	SignalBus.movement_failed.connect(_on_movement_failed)
	visible = false
func _on_movement_failed(reason:Constants.MovementFailureReason) -> void:
	match reason:
		Constants.MovementFailureReason.unit_is_boss:
			text = "Bosses can't be moved"
		Constants.MovementFailureReason.not_enough_money_for_purchase:
			text = "Not enough money"
		_:return
	position = get_global_mouse_position() - size * 0.5
	visible = true
	if tween: tween.kill()
	tween = create_tween().set_parallel()
	tween.tween_property(self, "position:y", -20, 0.5)\
	.as_relative()\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(self, "rotation", 0.0, 0.65)\
	.from(randf_range(-0.1,0.1))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)

	tween.tween_property(self, "scale", Vector2.ONE, 0.65)\
	.from(Vector2.ONE * randf_range(1.2,1.5))\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_callback(func () -> void: visible = false)\
	.set_delay(0.75)
