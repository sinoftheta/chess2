extends Node2D

var mouth_close_timer:int = 0

func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)


var menu_tween:Tween
func _on_menu_updated(cur:Constants.Menu, prev:Constants.Menu) -> void:
	
	if prev == Constants.Menu.none:
		## we're doing the opening animation
		pass
	
	var t:float = 0.5
	var letter_pos:Vector2
	var letter_alpha_:float = 1.0
	match cur:
		
		Constants.Menu.main:
			letter_pos = Vector2.ZERO
			letter_alpha_ = 1.0
		Constants.Menu.none:
			pass ## idk
		_:
			letter_pos = Vector2(0,20)
			letter_alpha_ = 0.0
			
		
		
	
	if menu_tween: menu_tween.kill()
	menu_tween = create_tween()\
	.set_parallel(true)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_SINE)
	
	menu_tween.tween_property(self, "position", Constants.menu_data[cur].position, t)
	menu_tween.tween_property(self, "scale", Constants.menu_data[cur].scale, t)
	menu_tween.tween_property(self,"letter_alpha", letter_alpha_, t)
	menu_tween.tween_property(%Letters, "position",   letter_pos,   t)
	
var letter_alpha:float:
	set(value):
		letter_alpha = value
		(%Face as Node2D).modulate.a = value
		((%Letters as Node2D).material as ShaderMaterial).set_shader_parameter("alpha", value)

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
