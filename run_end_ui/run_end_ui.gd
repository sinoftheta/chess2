extends Sprite2D


func _ready() -> void:
	SignalBus.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(phase:Constants.GamePhase) -> void:
	match phase:
		Constants.GamePhase.run_won:
			visible = true
			%Message.text = "You Won!"
			%Endless.visible = true
			self_modulate = Color("560029")
		Constants.GamePhase.run_lost:
			visible = true
			%Message.text = "You Lost!"
			%Endless.visible = false
			self_modulate = Color("002041")
		_: visible = false


func _on_new_run_pressed() -> void:
	SignalBus.start_game.emit()


func _on_endless_pressed() -> void:
	SignalBus.continue_run_pressed.emit()
