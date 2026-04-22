class_name BoxTile
extends Node2D

var tile: Vector2i
var punch_power: int = 10

var activation_tile: Vector2i = Vector2i.ZERO

func _enter_tree() -> void:
	pass
	

func move(to_cell: Vector2i) -> void:
	position = to_cell*64
	tile = UTIL.CellurizeVector(position)

func _rotate(dir: UTIL.DIRECTIONS) -> void:
	match dir:
		UTIL.DIRECTIONS.LEFT:
			rotation_degrees = 90
			activation_tile = Vector2i(-1, 0)
		UTIL.DIRECTIONS.RIGHT:
			rotation_degrees = -90
			activation_tile = Vector2i(1, 0)
		UTIL.DIRECTIONS.UP:
			rotation_degrees = 180
			activation_tile = Vector2i(0, -1)
		UTIL.DIRECTIONS.DOWN:
			rotation_degrees = 0
			activation_tile = Vector2i(0, 1)
		_:
			assert(false)
	

func _ready() -> void:
	tile = UTIL.CellurizeVector(global_position)
	GameEvents.ingame_board_eventer.soldier_moved.connect(_on_soldier_move)
	

func _on_soldier_move(e: Move) -> void:
	if e.target_location == (tile + activation_tile):
		var distance: int = 1
		
		for i:int in range(2, 11):
			var soldier_exists: bool = GameEvents.ingame_board_eventer.request_data(
				IngameBoardEventer.DATA_REQUESTS.DOES_SOLDIER_EXIST,
				tile + activation_tile*i
			)
			
			if soldier_exists == true:
				break
			else:
				distance += 1
		
		if distance > 1:
			GameEvents.ingame_board_eventer.request_soldier_move.emit(
				tile + activation_tile,
				tile + activation_tile*distance
			)
		
	
