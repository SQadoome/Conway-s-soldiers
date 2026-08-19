class_name MoveSet
extends Resource

var instructions: Array[MoveInstruction] = []

func _init(_insts: Array[MoveInstruction] = []) -> void:
	instructions = _insts;
	

func add_instruction(inst: MoveInstruction) -> void:
	instructions.append(inst);
	

func parse_moves(from: Vector2) -> Array[Move]:
	var moves: Array[Move] = [];
	
	for inst:MoveInstruction in instructions:
		if (not inst.can_play(from)):
			continue;
		moves.append(inst.parse(from));
		
	
	return moves;
	
