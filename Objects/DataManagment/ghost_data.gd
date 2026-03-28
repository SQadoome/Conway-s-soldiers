class_name GhostData
extends Resource

var victims: PackedVector2Array
var origin: Vector2i
var target: Vector2i
var ascension: bool

func _init(move: Move, ascension: bool = false) -> void:
	victims = move.victims
	origin = move.origin
	target = move.target_location
	self.ascension = ascension
