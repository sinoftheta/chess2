extends Node

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
