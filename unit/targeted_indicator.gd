extends Sprite2D

var init_position:Vector2
func _ready() -> void:
	init_position = position

func _process(delta: float) -> void:
	position = init_position + Vector2(
		0,
		3 * sin(Engine.get_frames_drawn() * 0.1)
	)

func _on_visibility_changed() -> void:
	set_process(visible)
