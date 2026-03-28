class_name MoveGenerator
extends Resource

#region DEFAULT-PRESETS

static var data: Dictionary[String, Callable] = {
	"standard": func() -> Array[Dictionary]:
		return GenerateDiagonalMoves() + GenerateNoramalMoves() + GenerateNoramalMoves(2),
	"classic": func() -> Array[Dictionary]:
		return GenerateNoramalMoves(),
	"classic_diagonals": func() -> Array[Dictionary]:
		return GenerateNoramalMoves() + GenerateDiagonalMoves() + GenerateNoramalMoves(8),
}

static func GeneratePresetInstructions(preset: String) -> MoveSet:
	return MoveSet.new(data[preset].call())

static func GenerateDiagonalMoves(distance: int = 1) -> Array[Dictionary]:
	var directions: PackedVector2Array = GetDiagonals()
	var moves: Array[Dictionary] = []
	
	for dir:Vector2i in directions:
		var instructions: Dictionary = {}
		instructions["target"] = distance*2 * dir
		instructions["victims"] = GetVictims(dir, distance)
		instructions["conditions"] = GetCondition(dir, distance)
		
		moves.append(instructions)
	
	return moves

static func GenerateNoramalMoves(distance: int = 1) -> Array[Dictionary]:
	var directions: PackedVector2Array = GetNormals()
	var moves: Array[Dictionary] = []
	
	for dir:Vector2i in directions:
		var instructions: Dictionary = {}
		instructions["target"] = (distance*2) * dir
		instructions["victims"] = GetVictims(dir, distance)
		instructions["conditions"] = GetCondition(dir, distance)
		
		moves.append(instructions)
	
	return moves


static func GetVictims(direction: Vector2i, distance: int) -> PackedVector2Array:
	var victims: PackedVector2Array = []
	for d:int in range(1, distance/2 + 2):
		victims.append(direction * d)
	return victims

static func GetCondition(direction: Vector2i, distance: int) -> Dictionary[Vector2i, bool]:
	var conditions: Dictionary[Vector2i, bool] = {}
	for d:int in range(1, distance*2 + 1):
		conditions[d*direction] = not d > distance
		
	return conditions

static func GetDiagonals() -> PackedVector2Array:
	var directions: PackedVector2Array = [
		Vector2(1, 1), Vector2(-1, 1),
		Vector2(1, -1), Vector2(-1, -1),
	]
	return directions

static func GetNormals() -> PackedVector2Array:
	var directions: PackedVector2Array = [
		Vector2(1, 0), Vector2(-1, 0),
		Vector2(0, 1), Vector2(0, -1),
	]
	return directions
#endregion

static func GenerateMoves(origin: Vector2i, move_set: MoveSet) -> Array[Move]:
	var moves: Array[Move] = []
	for instructions:MoveSet.MoveInstructions in move_set.moves_data:
		var victims: PackedVector2Array = []
		for direction:Vector2i in instructions.victims:
			victims.append(origin + direction)
		
		var conditions: Dictionary[Vector2i, bool] = {}
		for direction:Vector2i in instructions.conditions:
			conditions[origin + direction] = instructions.conditions[direction]
		
		var move: Move = Move.new(
			origin,
			origin + instructions.target,
			victims,
			conditions
		)
		moves.append(move)
	
	return moves
