extends Node2D

func _process(delta: float) -> void:
	var label: Label = get_node("Label")
	var mouse_cell: Vector2i = UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32))
	label.text = str(mouse_cell)
	global_position = get_global_mouse_position()
