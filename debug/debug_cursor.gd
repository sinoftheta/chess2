extends Node2D

func _ready() -> void:
	SignalBus.debug_update_cursor.connect(_on_debug_update_cursor)
	
func _on_debug_update_cursor(coord:Vector2i, board_id:Constants.BoardID) -> void:
	#visible = board_id == Constants.BoardID.none
	#if visible:
		#
	queue_redraw()

func _draw() -> void:
	if Debug.cursor_board_id == Constants.BoardID.none: return
	if not Options.debug: return
	
	var tile:Tile = \
	(GameLogic.tile_managers[Debug.cursor_board_id] as TileManager)\
	.get_node_or_null(Util.coord_to_name(Debug.cursor_coord))
	draw_rect(Rect2(tile.global_position, tile.size), Color.RED, false, 4)
