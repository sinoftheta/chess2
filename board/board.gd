class_name Board
extends Sprite2D

@export var id:Constants.BoardID
@export var logical_size:Vector2i
func _ready() -> void:
	GameLogic.boards[id] = self
	#print(id)
	#print(GameLogic.boards)
	set_process( texture != null)
	
