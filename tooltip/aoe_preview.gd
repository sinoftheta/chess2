extends Sprite2D

@export var tooltip:Tooltip
@export var color:Color

func _draw() -> void:
	var data:UnitData = Constants.unit_data[tooltip.unit.id]
	var is_boss:bool = data.type == Constants.UnitType.boss
	## Generate the aoe preview
	#data.aoe_is_absolute
	if is_boss:
		draw_rect(
			Rect2(Vector2.ZERO, get_rect().size),
			color
		)
	else:
		
		var bounds:Rect2i = Rect2i()
		for coord:Vector2i in data.aoe:
			bounds = bounds.expand(coord)
		bounds.size.x >> 1
		bounds.size.y >> 1
		
		var sidelength:float =\
		get_rect().size.x\
		/\
		float(maxi(bounds.size.y + 1, bounds.size.x + 1))
		
		(%UnitPreview as Sprite2D).scale = Vector2.ONE * sidelength / Constants.GRID_SIZE
		
		for coord:Vector2i in data.aoe:
			draw_rect(
				Rect2(get_rect().size * 0.5 + (Vector2(coord) - Vector2.ONE * 0.5) * sidelength, Vector2.ONE * sidelength),
				color
			)
			

		print(sidelength)
