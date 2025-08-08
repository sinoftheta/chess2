extends Node2D

func _ready() -> void:
	match OS.get_name():
		"Windows":
			print("Welcome to Windows!")
		"macOS":
			print("Welcome to macOS!")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			print("Welcome to Linux/BSD!")
		"Android":
			print("Welcome to Android!")
		"iOS":
			print("Welcome to iOS!")
		"Web":
			print("Welcome to Web!")
		
	MenuLogic.push(Constants.Menu.main)
	


func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		## quit handler
		get_tree().quit()


#func _process(delta: float) -> void:
#	%Test.position.y = 10*sin(Engine.get_frames_drawn()* 0.1)
