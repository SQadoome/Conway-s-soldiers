extends Node2D

@export var activation_detector: ActivationDetector;

const max_distance: int = 3

func _enter_tree() -> void:
	pass;
	

func _ready() -> void:
	activation_detector.activated.connect(_on_activation);
	activation_detector.set_tile(UTIL.cellurize_vector(global_position) + Vector2i.RIGHT);
	

func _on_activation(m: Move) -> void:
	print("Fuck")
	var directions: PackedVector2Array = UTIL.generate_orthogonal_directions();
	var tile: Vector2i = UTIL.cellurize_vector(global_position);
	print(directions)
	for dir:Vector2i in directions:
		var soldiers_detected: int = 0;
		
		for power:int in range(1, max_distance + 1):
			var soldier_exists: bool = GameEvents.ingame_board_eventer.request_data(
				IngameBoardEventer.DATA_REQUESTS.DOES_SOLDIER_EXIST, tile + dir*power);
			soldiers_detected += int(soldier_exists);
			print(soldier_exists)
			if not soldier_exists:
				break;
			
		if soldiers_detected > 0:
			GameEvents.ingame_board_eventer.request_soldier_move.emit(
				tile + dir*soldiers_detected, tile + dir*soldiers_detected + dir*max_distance
			);
		
	
