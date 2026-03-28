class_name LevelReader
extends Node

static var operations: Dictionary[String, Callable] = {
	"soldiers": PackedArrerorizeString,
	"ascensions": PackedArrerorizeString,
	"board": Nothing,
	"moves": ReadMovesInstructions,
	"level_tag": Nothing
}

static func ReadLevel(path: String = "") -> LevelData:
	if path == "":
		path = "res://Levels/Main/level_1.level"
	else:
		path = "res://Levels/Main/" + path
	print(path)
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var temp: Dictionary = JSON.parse_string(file.get_as_text())
	var data: Dictionary = {}
	
	for operation:String in temp.keys():
		if operations.has(operation):
			data[operation] = operations[operation].call(temp[operation])
	var level_data: LevelData = LevelData.new(data)
	return level_data

static func PackedArrerorizeString(string_array: Array) -> PackedVector2Array:
	var arr: PackedVector2Array = []
	for i:String in string_array:
		arr.append(VectorizeString(i))
	return arr

static func VectorizeString(text: String) -> Vector2i:
	var result: Vector2i = Vector2i.ZERO
	var sign: Vector2i = Vector2i(1, 1)
	var index: int = 1
	var digit_counter = 0
	var num_string: String = ""
	
	if text[index] == '-':
		sign.x = -1
		index += 1
	while true:
		num_string += text[index]
		digit_counter += 1
		
		if text[index] == ',':
			break
		index += 1
	
	result.x = int(num_string)
	index += 2
	digit_counter = 0
	num_string = ""
	
	if text[index] == '-':
		sign.y = -1
		index += 1
	while true:
		num_string += text[index]
		digit_counter += 1
		
		if text[index] == ')':
			break
		index += 1
	result.y = int(num_string)
	result = result*sign
	return result

static func BoolearizeString(text: String) -> bool:
	return (text[0] == 'f')

static func Nothing(text: String) -> String:
	return text

static func ReadMovesInstructions(moves: Dictionary) -> MoveSet:
	if moves.has("preset"):
		return MoveGenerator.GeneratePresetInstructions(moves["preset"])
	
	var total_moves: Array[Dictionary] = []
	
	for move:String in moves:
		var move_data: Dictionary = moves[move]
		
		var instructions: Dictionary = {}
		
		instructions["target"] = VectorizeString(move_data["target"])
		instructions["victims"] = PackedArrerorizeString(move_data["victims"])
		var conditions: Dictionary[Vector2i, bool] = {}
		
		for raw_condition:String in move_data["conditions"]:
			conditions[VectorizeString(raw_condition)] = move_data["conditions"][raw_condition]
		instructions["conditions"] = conditions
		total_moves.append(instructions)
	
	var move_set: MoveSet = MoveSet.new(total_moves)
	return move_set
