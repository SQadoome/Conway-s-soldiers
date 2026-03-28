class_name Move
extends Resource

var origin: Vector2i
var target_location: Vector2i

var victims: PackedVector2Array
var conditions: Dictionary[Vector2i, bool]

func _init(origin:Vector2i, target_location:Vector2i, victims:PackedVector2Array, conditions:Dictionary[Vector2i, bool]) -> void:
	self.origin = origin
	self.target_location = target_location
	self.victims = victims
	self.conditions = conditions
