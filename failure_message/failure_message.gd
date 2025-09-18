extends Label

var tween:Tween
func _ready() -> void:
	SignalBus.message_under_cursor.connect(_on_message_under_cursor)
	visible = false

func _on_message_under_cursor(message:String) -> void:
	print("huh")
	visible = true
	text = message
	position = get_global_mouse_position() - size * 0.5
	
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
