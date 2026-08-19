extends Node2D

@export var activation_detector: ActivationDetector;

const MAX_DISTANCE: int = 3

var cell: Vector2

func _enter_tree() -> void:
	pass;
	

func _ready() -> void:
	#activation_detector.activated.connect(_on_activation);
	activation_detector.set_tile(TileUtil.cellurize_vector(global_position) + Vector2i.RIGHT);
	
	cell = TileUtil.cellurize_vector(global_position);
	
