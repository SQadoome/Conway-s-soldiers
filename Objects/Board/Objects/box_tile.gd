class_name BoxTile
extends Node2D

@export var activation_detector: ActivationDetector

var punch_power: int = 10
var direction: Vector2i = Vector2i.RIGHT

func _enter_tree() -> void:
	activation_detector.activated.connect(_on_activation)
	activation_detector.set_tile(UTIL.cellurize_vector(position) + direction)

func move(to_cell: Vector2i) -> void:
	position = to_cell*64

func _rotate(dir: UTIL.DIRECTIONS) -> void:
	pass
	

func _on_activation(e: Move) -> void:
	var distance: int = 1
	
	for i:int in range(2, 11):
		var soldier_exists: bool = GameEvents.ingame_board_eventer.request_data(
			IngameBoardEventer.DATA_REQUESTS.DOES_SOLDIER_EXIST,
			UTIL.cellurize_vector(position) + direction*i
	)
		
		if soldier_exists == true:
			break
		else:
			distance += 1
		
	
	GameEvents.ingame_board_eventer.request_soldier_move.emit(
		UTIL.cellurize_vector(position) + direction,
		UTIL.cellurize_vector(position) + direction*distance
	)
	
