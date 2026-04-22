class_name IngameBoardEventer
extends Resource

class BrokenHeight extends Resource:
	var height: int
	var tile: Vector2i
	func _init(height: int, tile: Vector2i) -> void:
		self.tile = tile
		self.height = height
		
	func _to_string() -> String:
		return ("Broken height: " + str(height) + " | tile coords: " + str(tile))

class Ascension extends Resource:
	var ascend_tile: Vector2i
	var hook_tile: Vector2i
	func _init(ascend_tile: Vector2i, hook_tile: Vector2i) -> void:
		self.ascend_tile = ascend_tile
		self.hook_tile = hook_tile
		
	func _to_string() -> String:
		return ("Ascension: ascend_tile: " + str(ascend_tile) + " | hook tile: " + str(hook_tile))

class UndoSoldierMove extends Resource:
	var origin: Vector2i
	var destination: Vector2i
	var victims: PackedVector2Array
	func _init(data: Move) -> void:
		self.origin = data.origin
		self.destination = data.target_location
		self.victims = data.victims
		
	func _to_string() -> String:
		return ("Undid move: " + str(origin) + " <- " + str(destination) + " | victims: " + str(victims))


enum DATA_REQUESTS {
	DOES_SOLDIER_EXIST = 0,
}
var data_requests: Array[Callable] = []

var BOARD: InfiniteInternal
func set_board(_BOARD: InfiniteInternal) -> void:
	BOARD = _BOARD
	data_requests.resize(DATA_REQUESTS.size())
	data_requests[DATA_REQUESTS.DOES_SOLDIER_EXIST] = func(arg: Variant) -> bool:
		return BOARD.does_soldier_exist(arg as Vector2i)
	
	

func request_data(request: DATA_REQUESTS, arg: Variant) -> Variant:
	assert(DATA_REQUESTS.size() == data_requests.size(), "Missing data requests!")
	return data_requests[request].call(arg)

signal ascension(a: Ascension)
signal height_broken(h: BrokenHeight)
signal soldier_moved(s: Move)
signal undo_soldier_move(d: UndoSoldierMove)

signal request_soldier_move(from: Vector2i, to: Vector2i)
signal request_place_soldier(tile: Vector2i)
signal request_remove_soldier(tile: Vector2i)

signal leave
signal reset
signal finish
