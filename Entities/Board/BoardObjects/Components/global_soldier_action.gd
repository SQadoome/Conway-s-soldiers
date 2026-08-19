class_name GlobalSoldierAction
extends ObjectActionComponent

var current_cell: Vector2

var moves: Array[Move] = []

func _init() -> void:
	super();
	

func add_move(move: MoveSet) -> void:
	moves.append(move);
	

func action() -> void:
	pass
	
