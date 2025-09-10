extends Node2D

var mouth_close_timer:int = 0

func _process(delta:float) -> void:
	if randi() % 400 <= 2 and (%LeftEye as AnimatedSprite2D).animation == "default":
		(%LeftEye  as AnimatedSprite2D).play("blink")
		(%RightEye as AnimatedSprite2D).play("blink")
		
	#if Engine.get_frames_drawn() > 100 and (%Mouth as AnimatedSprite2D).animation == "closed":
		#(%Mouth as AnimatedSprite2D).play("open")
		
	%Face.position = lerp(%Face.position, (get_global_mouse_position() * scale.x).limit_length(7), minf(delta * 1.0, 1.0))
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouth_close_timer += 1
	else:
		mouth_close_timer = 0
		if (%Mouth as AnimatedSprite2D).animation == "close":
			(%Mouth as AnimatedSprite2D).play("open")
			
	if mouth_close_timer >= 5 and (%Mouth as AnimatedSprite2D).animation == "open":
		(%Mouth as AnimatedSprite2D).play("close")
		
	
	

func _on_left_eye_animation_finished() -> void:
	match (%LeftEye as AnimatedSprite2D).animation:
		"blink":
			(%LeftEye  as AnimatedSprite2D).play("default")
			(%RightEye as AnimatedSprite2D).play("default")
		"default":pass
