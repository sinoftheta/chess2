extends Sprite2D


func _process(delta: float) -> void:
	scale = Vector2(
		1.05 + 0.05 * sin(Engine.get_frames_drawn() * 0.03),
		1.1 + 0.1  * cos(Engine.get_frames_drawn() * 0.05),
	)
