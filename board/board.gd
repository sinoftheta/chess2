class_name Board
extends Sprite2D

@export var id:Constants.BoardID
@export var logical_size:Vector2i
func _ready() -> void:
	GameLogic.boards[id] = self
	set_process( texture != null)
	
func _process(delta: float) -> void:
	
	if Rect2(global_position,global_scale * texture.get_size())\
	.has_point(get_global_mouse_position()):

		var local:Vector2 = to_local(get_global_mouse_position())

		local.x /= global_scale.x * texture.get_size().x
		local.y /= global_scale.y * texture.get_size().y
		
		MouseLogic.board_id_under_cursor = id
		MouseLogic.coord_under_cursor = Vector2i(
			int(local.x * logical_size.x),
			int(local.y * logical_size.y)
		)

		print(Constants.BoardID.keys()[id], ", ", MouseLogic.coord_under_cursor)
