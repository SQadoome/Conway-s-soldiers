class_name SmartCamera
extends Camera2D

signal camera_shifted(new_cell: Vector2i)

var dead_zone: Vector2 = Vector2(0, 128)
var old_cell: Vector2i = Vector2.ZERO

func vec_2_cell(pos: Vector2) -> Vector2i:
	var cell: Vector2i
	cell = Vector2i(
		floori(pos.x/64),
		floori(pos.y/64)
	)
	return cell
	

func MoveTo(location: Vector2) -> void:
	old_cell = vec_2_cell(location)
	position = location

func SimulateShift(new_cell: Vector2i) -> void:
	emit_signal("camera_shifted", new_cell)
	position = new_cell*64
	old_cell = new_cell

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position.x -= event.relative.x
			
			if position.y - event.relative.y > -12*64 - 1080:
				position.y -= event.relative.y
			var new_cell: Vector2i = vec_2_cell(position)
			
			emit_signal("camera_shifted", new_cell)
			old_cell = new_cell
			
		
