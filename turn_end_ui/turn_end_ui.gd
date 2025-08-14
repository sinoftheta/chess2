extends Sprite2D
func _ready() -> void:
	SignalBus.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(phase:Constants.GamePhase) -> void:
	visible = phase == Constants.GamePhase.end_of_turn


func _on_next_turn_button_pressed() -> void:
	SignalBus.next_turn_pressed.emit()
