extends Node

var unit_tscn:PackedScene = preload("res://unit/unit.tscn")
var boards:Dictionary[Constants.BoardID, Board]

var executing:bool

var hovered_board_id:Constants.BoardID
func hovered_coord() -> Vector2i:
	var cur_board:Board = boards[hovered_board_id]
	var bp:Vector2 = cur_board.global_position - cur_board.get_global_mouse_position() # + cur_board.size * 0.5 if we wanna meke the boards expandable???
	return Vector2i(floori(-bp.x / Constants.GRID_SIZE),floori(-bp.y / Constants.GRID_SIZE))

func _process(delta: float) -> void:
	
	print("=======")
	print(Constants.BoardID.keys()[hovered_board_id])
	print(hovered_coord())


func unit_at(coord:Vector2i, board_id:Constants.BoardID) -> Unit:
	return boards[board_id].get_node(Util.coord_to_name(coord))

func _ready() -> void:
	pass

func start_game() -> void:
	executing = false
	
func execute_shop_reroll() -> void:
	executing = true
	executing = false

## returns true if the drag is legal, false if not
func _object_moved(object, to_location, to_board_id) -> bool:
	if executing:
		return false
	return true

func execute_turn() -> void:
	executing = true
	executing = false


## USE Node.get_node(coord) to reach units by their coord
