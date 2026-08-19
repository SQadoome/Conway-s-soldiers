class_name MoveInstruction
extends RefCounted

var target: Vector2

func calculate_victims(at_cell: Vector2) -> PackedVector2Array:
	return [];
	

func can_play(at_cell) -> bool:
	return false;
	

func parse(at_cell: Vector2) -> Move:
	return null;
	
