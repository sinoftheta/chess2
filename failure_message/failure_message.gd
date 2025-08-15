extends Label

var tween:Tween
func _ready() -> void:
	SignalBus.failed_to_move_boss.connect(_on_failed_to_move_boss)
	SignalBus.cant_afford_purchase.connect(_on_cant_afford_purchase)
	visible = false

func _on_cant_afford_purchase() -> void:
	play_message_under_cursor("Not enough money")
func _on_failed_to_move_boss() -> void:
	play_message_under_cursor("Bosses can't move")

func play_message_under_cursor(message:String) -> void:
	text = message
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
