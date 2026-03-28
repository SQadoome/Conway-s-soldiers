class_name LevelData
extends Resource

var ascensions: PackedVector2Array = []
var soldier_locations: PackedVector2Array = []
var board_type: String = ""
var move_set: MoveSet
var level_name: String

var operations: Dictionary[String, Callable] = {
	"soldiers": func(dic: Dictionary): soldier_locations = dic["soldiers"],
	"ascensions": func(dic: Dictionary): ascensions = dic["ascensions"],
	"board": func(dic: Dictionary): board_type = dic["board"] ,
	"moves": func(dic: Dictionary): move_set = dic["moves"],
	"level_tag": func(dic: Dictionary): level_name = dic["level_tag"],
}

func _init(data: Dictionary) -> void:
	for op:String in data:
		assert(operations.has(op), "Unkown data operation: " + op)
		
		operations[op].call(data)
