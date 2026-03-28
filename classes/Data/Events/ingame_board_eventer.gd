class_name IngameBoardEventer
extends Resource

class BrokenHeight extends Resource:
	var height: int
	var tile: Vector2i
	func _init(height: int, tile: Vector2i) -> void:
		self.tile = tile
		self.height = height
		print(_to_string())
	func _to_string() -> String:
		return ("Broken height: " + str(height) + " | tile coords: " + str(tile))

class Ascension extends Resource:
	var ascend_tile: Vector2i
	var hook_tile: Vector2i
	func _init(ascend_tile: Vector2i, hook_tile: Vector2i) -> void:
		self.ascend_tile = ascend_tile
		self.hook_tile = hook_tile
		print(_to_string())
	func _to_string() -> String:
		return ("Ascension: ascend_tile: " + str(ascend_tile) + " | hook tile: " + str(hook_tile))

class SoldierMoved extends Resource:
	var origin: Vector2i
	var destination: Vector2i
	var victims: PackedVector2Array
	func _init(move_data: GhostData) -> void:
		self.origin = move_data.origin
		self.destination = move_data.target
		self.victims = move_data.victims
		print(_to_string())
	func _to_string() -> String:
		return ("Soldier move: " + str(origin) + " -> " + str(destination) + " | victims: " + str(victims))

class UndoSoldierMove extends Resource:
	var origin: Vector2i
	var destination: Vector2i
	var victims: PackedVector2Array
	func _init(data: Move) -> void:
		self.origin = data.origin
		self.destination = data.target_location
		self.victims = data.victims
		print(_to_string())
	func _to_string() -> String:
		return ("Undid move: " + str(origin) + " <- " + str(destination) + " | victims: " + str(victims))

class SoldierCheck extends Resource:
	var tile: Vector2i
	var does_exist: bool
	func _init(tile: Vector2i, does_exist: bool) -> void:
		self.tile = tile
		self.does_exist = does_exist

signal ascension(a: Ascension)
signal height_broken(h: BrokenHeight)
signal soldier_moved(s: SoldierMoved)
signal undo_soldier_move(d: UndoSoldierMove)
signal request_soldier_move(tile: Vector2i)
signal request_check_soldier
signal request_check_soldier_accept(sc: SoldierCheck)
signal request_place_soldier(tile: Vector2i)
signal request_remove_soldier(tile: Vector2i)
signal leave
signal reset
signal finish
