class_name OrthogonalInstruction
extends MoveInstruction

var power: int
var direction: Vector2

func _init(_direction: Vector2, _power: int = 1) -> void:
	power = _power;
	direction = _direction;
	

func calculate_victims(at_cell: Vector2) -> PackedVector2Array:
	var victims: PackedVector2Array = [];
	var cell := Vector2(target - direction);
	
	if (BoardObjectManager.does_soldier_exist(cell)):
		victims.append(cell);
	victims.append(at_cell);
	
	return victims;

func can_play(at_cell: Vector2) -> bool:
	target = at_cell + direction*2;
	var cell := Vector2(at_cell + direction);
	
	var can: bool = BoardObjectManager.does_soldier_exist(cell) and\
		not BoardObjectManager.does_soldier_exist(target)
	
	return can;

func parse(at_cell: Vector2) -> Move:
	target = at_cell + direction*2
	
	var move := Move.new();
	move.victims = calculate_victims(at_cell);
	move.origin = at_cell;
	move.target_location = target;
	
	return move;
