class_name MoveReader
extends Resource


## needs a function to determine if a soldier in said tile exists
static func ReadMoves(unfiltered_moves: Array[Move], existing_checker: Callable) -> Array[Move]:
	var filtered_moves: Array[Move] = []
	for move:Move in unfiltered_moves:
		if IsValidMove(move, existing_checker):
			filtered_moves.append(move)
		
	return filtered_moves

static func IsValidMove(move: Move, existing_checker: Callable) -> bool:
	for cell:Vector2i in move.conditions.keys():
		if not (existing_checker.call(cell) == move.conditions[cell]):
			return false
		
	return true
