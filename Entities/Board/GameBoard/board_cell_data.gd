class_name BoardCellData
extends Resource

var is_occupied: bool = false
var occupation: Node2D = null

var at_tile: Vector2

func set_tile(tile: Vector2) -> void:
	at_tile = tile;
	

func set_occupation(object: Node2D) -> void:
	occupation = object;
	is_occupied = true;
	
