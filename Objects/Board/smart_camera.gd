class_name SmartCamera
extends Camera2D

signal camera_shifted(old_cell: Vector2i, new_cell: Vector2i)
signal camera_scaled(old_zoom: Vector2, new_zoom: Vector2)

var x_view: Vector2 = Vector2.ZERO
var y_view: Vector2 = Vector2.ZERO
var limit: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var old_cell: Vector2i = Vector2i.ZERO

const MAX_ZOOM: Vector2 = Vector2(2.1, 2.1)
const MIN_ZOOM: Vector2 = Vector2(0.4, 0.4)

func set_boundires(boundry: Rect2) -> void:
	# boundry is good
	
	# boundry is to small
	
	pass

func move_camera(event: InputEventMouseMotion) -> void:
	position -= event.relative/zoom
	
	var new_cell: Vector2i = UTIL.cellurize_vector(position)
	if new_cell != old_cell:
		camera_shifted.emit(old_cell, new_cell)
		old_cell = new_cell
	

func scale_camera(direction: int) -> void:
	var new_zoom: Vector2 = zoom + Vector2(direction, direction)*0.1
	if not new_zoom < MIN_ZOOM and not new_zoom > MAX_ZOOM:
		zoom = new_zoom
		print(zoom)
	

func simulate_shift(by_cells: Vector2i) -> void:
	assert(not by_cells == Vector2i.ZERO)
	
	var new_cell: Vector2i = old_cell + by_cells
	position += Vector2(by_cells*64)
	camera_shifted.emit(old_cell, new_cell)
	old_cell = new_cell
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			move_camera(event as InputEventMouseMotion)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scale_camera(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scale_camera(-1)
	
