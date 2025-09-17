class_name PipeSegment
extends Node2D


@export var order:int = 0
@export var total:int = 1
@export_range(0.0,1.0,0.01) var fill_animation:float:
	set(value):
		fill_animation = value
		
		(%Water as Sprite2D).frame_coords.x = roundi(
			(%Water as Sprite2D).hframes * 
			clampf(
				inverse_lerp(
					float(order), 
					float(order + 1), 
					fill_animation * total
				), 
				0.0, 
				1.0
			)
		)
		
@export var segment_type:Constants.PipeSegmentType:
	set(value):
		segment_type = value
		
		var y_coord:int
		var flip_h:bool
		var r:float = 0.0
		if not is_node_ready(): return
		
		match value:
				Constants.PipeSegmentType.start_to_right:
					y_coord = 0
					flip_h = false
					r = 0
				#Constants.PipeSegmentType.start_to_top,\
				#Constants.PipeSegmentType.start_to_left,\
				#Constants.PipeSegmentType.start_to_bottom:
				#	pass
				
				Constants.PipeSegmentType.right_to_top:
					y_coord = 2
					flip_h = true
					r = 0
				Constants.PipeSegmentType.right_to_left:
					y_coord = 1
					flip_h = true
					r = 0
				Constants.PipeSegmentType.right_to_bottom:
					y_coord = 2
					flip_h = true
					r = 180
				Constants.PipeSegmentType.top_to_right:
					flip_h = false
					y_coord = 2
					r = 90
				Constants.PipeSegmentType.top_to_left:
					y_coord = 2
					flip_h = true
					r = -90
				Constants.PipeSegmentType.top_to_bottom:
					y_coord = 1
					flip_h = false
					r = 90
				
				Constants.PipeSegmentType.left_to_right:
					y_coord = 1
					flip_h = false
					r = 0
				Constants.PipeSegmentType.left_to_top:
					y_coord = 2
					flip_h = false
					r = 0
				Constants.PipeSegmentType.left_to_bottom:
					y_coord = 2
					flip_h = false
					r = 180
				Constants.PipeSegmentType.bottom_to_right:
					y_coord = 2
					flip_h = true
					r = 90
				Constants.PipeSegmentType.bottom_to_top:
					y_coord = 1
					flip_h = true
					r = 90
				Constants.PipeSegmentType.bottom_to_left:
					y_coord = 2
					flip_h = false
					r = -90
		
		(%Fill    as Sprite2D).frame_coords.y = y_coord
		(%Water   as Sprite2D).frame_coords.y = y_coord
		(%Outline as Sprite2D).frame_coords.y = y_coord

		(%Fill    as Sprite2D).flip_h = flip_h
		(%Water   as Sprite2D).flip_h = flip_h
		(%Outline as Sprite2D).flip_h = flip_h
		
		(%Fill    as Sprite2D).rotation_degrees = r
		(%Water   as Sprite2D).rotation_degrees = r
		(%Outline as Sprite2D).rotation_degrees = r
		
		(%DebugLabel as Label).text = Constants.PipeSegmentType.keys()[value]


func _on_ready() -> void:
	segment_type = segment_type
