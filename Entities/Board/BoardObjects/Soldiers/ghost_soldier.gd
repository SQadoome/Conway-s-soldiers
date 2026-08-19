class_name GhostSoldier
extends Node2D

var move_data: Move
var rect: Rect2

signal chosen(move: Move)

func set_props(_move_data: Move) -> void:
	move_data = _move_data;
	position = TileUtil.vectorize_cell(move_data.target_location);
	var cell_size := Vector2(TileUtil.tile_size, TileUtil.tile_size);
	rect = Rect2(position - cell_size/2, cell_size);
	

func _ready() -> void:
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		
		if rect.has_point(get_global_mouse_position()):
			selected();
	

func selected() -> void:
	chosen.emit(move_data);
	queue_free();
	
