extends Node2D



func _ready() -> void:
	GameLogic.pipe_segments = self
	SignalBus.game_started.connect(_on_game_started)
	
const UP:Vector2i         = Vector2i( 0,-1)
const DOWN:Vector2i       = Vector2i( 0, 1)
const LEFT:Vector2i       = Vector2i(-1, 0)
const RIGHT:Vector2i      = Vector2i( 1, 0)

func _on_game_started() -> void:
	while get_child_count() > 0:
		var p:PipeSegment = get_child(0)
		remove_child(p)
		p.queue_free()
	
	var board_eval_order:Array[Vector2i] = Util.board_evaluation_order()
	
	var i:int = 0
	for coord:Vector2i in board_eval_order:
		
		if i == 0:
			var pipe_dir_to_next:Vector2i
		
		if i == board_eval_order.size() - 1:
			var pipe_dir_to_prev:Vector2i
		
		var pipe_dir_to_prev:Vector2i
		var pipe_dir_to_next:Vector2i
		
		
		
		
		i += 1
		
