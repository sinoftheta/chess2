class_name Tile
extends Node2D


@export var type:Constants.TileType:
	set(value):
		type = value
		
		var r:float = 0
		var flip_h:bool = false
		var vframe:int = 0
		
		match type:
			Constants.TileType.start_to_right:
				r = 0
				flip_h = false
				vframe = 1
			Constants.TileType.start_to_top:
				r = 90
				flip_h = false
				vframe = 1
			Constants.TileType.start_to_left:
				r = 180
				flip_h = false
				vframe = 1
			Constants.TileType.start_to_bottom:
				r = -90
				flip_h = false
				vframe = 1
			
			Constants.TileType.right_to_top:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.right_to_left:
				r = 180
				flip_h = false
				vframe = 2
			Constants.TileType.right_to_bottom:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.right_to_end:
				r = 0
				flip_h = false
				vframe = 3
			
			Constants.TileType.top_to_right:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.top_to_left:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.top_to_bottom:
				r = -90
				flip_h = false
				vframe = 2
			Constants.TileType.top_to_end:
				r = 0
				flip_h = false
				vframe = 3
			
			Constants.TileType.left_to_right:
				r = 0
				flip_h = false
				vframe = 2
			Constants.TileType.left_to_top:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.left_to_bottom:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.left_to_end:
				r = 0
				flip_h = false
				vframe = 3
			
			Constants.TileType.bottom_to_right:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.bottom_to_top:
				r = 90
				flip_h = false
				vframe = 2
			Constants.TileType.bottom_to_left:
				r = 0
				flip_h = false
				vframe = 0
			Constants.TileType.bottom_to_end:
				r = 0
				flip_h = false
				vframe = 3
		
		(%Type as Sprite2D).flip_h = flip_h
		(%TypeAnimation as Sprite2D).flip_h = flip_h
		(%Type as Sprite2D).rotation_degrees = r
		(%TypeAnimation as Sprite2D).rotation_degrees = r
		(%Type as Sprite2D).frame_coords.y = vframe
		(%TypeAnimation as Sprite2D).frame_coords.y = vframe

func _on_ready() -> void:
	type = type
