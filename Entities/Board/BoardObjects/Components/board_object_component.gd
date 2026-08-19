class_name BObjectComponent
extends Resource

enum Components {
	ACTION
}

var type: Components
var board_object: BoardObject

func _init(_type: Components) -> void:
	type = _type;
	
