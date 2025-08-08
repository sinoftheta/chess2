extends Node

static func coord_to_name(coord:Vector2i) -> String:
	return str(coord.x) + "_" + str(coord.y)

static func name_to_coord(_name:String) -> Vector2i:
	return Vector2i(
		int(_name.get_slice("_", 0)),
		int(_name.get_slice("_", 1)),
	)
