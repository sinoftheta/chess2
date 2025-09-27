extends Node

static func coord_to_name(coord:Vector2i) -> String:
	return str(coord.x) + "_" + str(coord.y)

static func name_to_coord(_name:String) -> Vector2i:
	return Vector2i(
		int(_name.get_slice("_", 0)),
		int(_name.get_slice("_", 1)),
	)
const MAXINT = 9223372036854775807

func int_to_string(i:int) -> String:
	if i == MAXINT:
		return "MAXINT"
	if i < 0:
		return "lt0"
	var p:int = floori(log(i)/log(10))
	
	var s:String = ""
	var d:float
	print(p)
	match p:
		3,4,5: 
			s = "K"
			d = 1_000
		6,7,8:
			s = "M"
			d = 1_000_000
		9,10,11:
			s = "B"
			d = 1_000_000_000
		12,13,14:
			s = "T"
			d = 1_000_000_000_000
		15,16,17:
			s ="P"
			d = 1_000_000_000_000_000
		18,19,20:
			s ="E"
			d = 1_000_000_000_000_000_000
		_: return str(i)
	
	return str(float(i) / d)\
	.left(4)\
	.trim_suffix(".")\
	.trim_suffix(".0") + s

static func board_evaluation_order() -> Array[Vector2i]: ## TODO: THIS SHOULD GO IN A/THE UTILITY SCRIPT
	var diameter:int = 5
	var ordering:Array[Vector2i] = []

	var cur:Vector2i = Vector2i.ZERO
	var o:Vector2i = Vector2i.ONE * (diameter >> 1)
	## https://math.stackexchange.com/questions/163080/on-a-two-dimensional-grid-is-there-a-formula-i-can-use-to-spiral-coordinates-in
	## generate the sequence:
	## rd|lluu|rrrddd|lllluuuu|rrrrrddddd|...
	ordering.push_back(cur + o)
	for i:int in range(1,diameter + 1):
		
		## cut off last half pass
		var first_pass_range:Array
		if i == diameter:
			first_pass_range = range(i - 1)
		else:
			first_pass_range = range(i)
		
		
		for j:int in first_pass_range:
			if i % 2 == 0:
				## travel right
				cur += Constants.RIGHT
			else:
				## travel left
				cur += Constants.LEFT
			ordering.push_back(cur + o)
			
			
		if i == diameter:
			break
		
		for j:int in range(i):
			if i % 2 == 0:
				## travel down
				cur += Constants.DOWN
			else:
				## travel up
				cur += Constants.UP
			ordering.push_back(cur + o)
	return ordering
	
static func int_ordinal_suffix(i:int) -> String:
	var j:int = i % 10
	var k:int = i % 100
	if j == 1 and k != 11:
		return str(i) + "st"
	if j == 2 and k != 12:
		return str(i) + "nd"
	if j == 3 and k != 13:
		return str(i) + "rd"
	return str(i) + "th"

static func format_number(num:Variant) -> String:
	if not(num is float) and not(num is int):
		return "err"
	var text:String = String.num(num, 3)
	text = text.trim_suffix(".0")
	if absf(num) > 1.0E10:
		text = String.num_scientific(num)
	return text
	
static func string_to_aoe(string:String) -> Array[Vector2i]:
	var r:Array[Vector2i] = []
	var s:String = string.dedent()
	if s.begins_with("\n"):
		s = s.substr(1)
	var width:int = s.find("\n")
	var i:int = 0
	
	var center:Vector2i = Vector2i((width >> 1) + 1, (width >> 1) + 1)
	
	for row:int in range(width):
		for col:int in range(width):
			match s[i]:
				"x":
					center = Vector2i(row,col)
				"0":
					r.push_back(Vector2i(row,col))
				_:pass
			
			i += 1
		i += 1
	
	for j:int in range(r.size()):
		r[j] -= center
	
	return r
