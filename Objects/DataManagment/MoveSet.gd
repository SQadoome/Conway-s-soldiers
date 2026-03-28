class_name MoveSet
extends Resource

## the MoveInstructions holds data for directions of the move from an origin not the final
## result for the move
class MoveInstructions extends Resource:
	var target: Vector2i
	var victims: PackedVector2Array
	var conditions: Dictionary[Vector2i, bool]
	func _init(target: Vector2i, victims: PackedVector2Array, conditions: Dictionary[Vector2i, bool]) -> void:
		self.target = target
		self.victims = victims
		self.conditions = conditions
	func _to_string() -> String:
		return "target: " + str(target) + " | victims: " + str(victims) + " | conditions: " + str(conditions)

var moves_data: Array[MoveInstructions] = []

func _init(data: Array[Dictionary]) -> void:
	for dic:Dictionary in data:
		moves_data.append(
			MoveInstructions.new(
				dic["target"], dic["victims"], dic["conditions"]
			)
		)
	pass
