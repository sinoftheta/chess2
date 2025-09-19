class_name TileManager
extends Node2D

@export var id:Constants.BoardID


var tile_tscn:PackedScene = preload("res://tiles/tile.tscn")
func _ready() -> void:
	GameLogic.tile_managers[id] = self
	SignalBus.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	clear_board()
	setup_board(GameLogic.boards[id].logical_size)
	if id == Constants.BoardID.play:
		set_order_chevrons(GameLogic.board_evaluation_order)
	
enum PathPart {
	start,
	end,
	left,
	right,
	top,
	bottom,
}
const UP:Vector2i         = Vector2i( 0,-1)
const DOWN:Vector2i       = Vector2i( 0, 1)
const LEFT:Vector2i       = Vector2i(-1, 0)
const RIGHT:Vector2i      = Vector2i( 1, 0)

func set_order_chevrons(board_evaluation_order:Array[Vector2i]) -> void:
	for i:int in board_evaluation_order.size():
		var coord:Vector2i = board_evaluation_order[i]
		
		var prev_part:PathPart = PathPart.start
		var next_part:PathPart = PathPart.end
		
		if (i - 1) >= 0:
			var prev_coord:Vector2i = board_evaluation_order[i - 1]
			match prev_coord - coord:
				UP:    prev_part = PathPart.top
				DOWN:  prev_part = PathPart.bottom
				LEFT:  prev_part = PathPart.left
				RIGHT: prev_part = PathPart.right
			
		
		if (i + 1) < board_evaluation_order.size():
			var next_coord:Vector2i = board_evaluation_order[i + 1]
			match next_coord - coord:
				UP:    next_part = PathPart.top
				DOWN:  next_part = PathPart.bottom
				LEFT:  next_part = PathPart.left
				RIGHT: next_part = PathPart.right
		
		var tile_type:Constants.TileType
		## man we could just use this encoding directly in the Tile class oh well
		match Vector2i(prev_part, next_part):
			Vector2i(PathPart.start, PathPart.end): assert(false) #Constants.TileType.start_to_end
			
			Vector2i(PathPart.start, PathPart.top): tile_type = Constants.TileType.start_to_top
			Vector2i(PathPart.start, PathPart.bottom): tile_type = Constants.TileType.start_to_bottom
			Vector2i(PathPart.start, PathPart.left): tile_type = Constants.TileType.start_to_left
			Vector2i(PathPart.start, PathPart.right): tile_type = Constants.TileType.start_to_right
			
			Vector2i(PathPart.left, PathPart.top): tile_type = Constants.TileType.left_to_top
			Vector2i(PathPart.left, PathPart.bottom): tile_type = Constants.TileType.left_to_bottom
			Vector2i(PathPart.left, PathPart.right): tile_type = Constants.TileType.left_to_right
			Vector2i(PathPart.left, PathPart.end): tile_type = Constants.TileType.left_to_end
			
			Vector2i(PathPart.right, PathPart.top): tile_type = Constants.TileType.right_to_top
			Vector2i(PathPart.right, PathPart.bottom): tile_type = Constants.TileType.right_to_bottom
			Vector2i(PathPart.right, PathPart.left): tile_type = Constants.TileType.right_to_left
			Vector2i(PathPart.right, PathPart.end): tile_type = Constants.TileType.right_to_end
			
			Vector2i(PathPart.top, PathPart.bottom): tile_type = Constants.TileType.top_to_bottom
			Vector2i(PathPart.top, PathPart.left): tile_type = Constants.TileType.top_to_left
			Vector2i(PathPart.top, PathPart.right): tile_type = Constants.TileType.top_to_right
			Vector2i(PathPart.top, PathPart.end): tile_type = Constants.TileType.top_to_end
			
			Vector2i(PathPart.bottom, PathPart.top): tile_type = Constants.TileType.bottom_to_top
			Vector2i(PathPart.bottom, PathPart.left): tile_type = Constants.TileType.bottom_to_left
			Vector2i(PathPart.bottom, PathPart.right): tile_type = Constants.TileType.bottom_to_right
			Vector2i(PathPart.bottom, PathPart.end): tile_type = Constants.TileType.bottom_to_end
			
		var tile:Tile = get_node_or_null(Util.coord_to_name(coord))
		if not tile: assert(false)
		tile.type = tile_type
		tile.order = i
			
	
func setup_board(logical_size:Vector2i) -> void:
	for x:int in range(logical_size.x):
		for y:int in range(logical_size.y):
			var tile:Tile = tile_tscn.instantiate()
			tile.logical_position = Vector2i(x,y)
			tile.board_id = id
			add_child(tile) ## tiles with a high y val are added to the tree last... this is what we want
	
	
func clear_board() -> void:
	while get_child_count() > 0:
		var tile:Tile = get_child(0)
		remove_child(tile)
		tile.queue_free()
