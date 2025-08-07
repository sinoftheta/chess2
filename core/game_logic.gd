extends Node

var game_board:Node2D
var boards:Array[Node2D]

var executing:bool


func unit_at(coord:Vector2i, board_id:Constants.BoardID) -> Unit:
	return boards[board_id].get_node(Util.coord_to_name(coord))

func _ready() -> void:
	#boards.push_back(game_board)
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
