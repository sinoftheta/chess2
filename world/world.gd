extends Node2D

func _ready() -> void:
	SignalBus.menu_updated.connect(_on_menu_updated)
	SignalBus.money_changed.connect(_on_money_changed)
	SignalBus.turn_changed.connect(_on_turn_changed)
	SignalBus.round_changed.connect(_on_round_changed)
	SignalBus.reroll_price_changed.connect(_on_reroll_price_changed)

func _on_money_changed(new:int,prev:int) -> void:
	%MoneyValue.text = "$" + str(new)
func _on_turn_changed(turn:int) -> void:
	%TurnValue.text = str(turn)
func _on_round_changed(round:int) -> void:
	%RoundValue.text = str(round) + "/" + str(GameLogic.max_rounds)
func _on_reroll_price_changed(price:int) -> void:
	%Reroll.text = "Reroll $" + str(price)

func _on_menu_updated(menu:Constants.Menu) -> void:
	visible = menu == Constants.Menu.gameplay


func _on_play_pressed() -> void:
	SignalBus.play_button_pressed.emit()
func _on_reroll_pressed() -> void:
	SignalBus.reroll_button_pressed.emit()
