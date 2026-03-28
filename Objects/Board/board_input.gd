class_name BoardInput
extends Node2D

signal cell_clicked_left(cell: Vector2i)
signal cell_clicked_right(cell: Vector2i)
signal highlight_request(cell: Vector2i)
signal mouse_cell_changed(cell: Vector2i)
signal rect_selected(from: Vector2i, rect: Vector2i)

signal undo_request
signal mouse_held
signal mouse_stopped_held

var is_mouse_held: bool = false
var is_mouse_clicked: bool = false

func _unhandled_input(event: InputEvent) -> void:
	var mouse_cell: Vector2i = UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32))
	if event.is_action_pressed("ui_accept"):
		anchor = mouse_cell
		is_mouse_clicked = true
		emit_signal("cell_clicked_left", mouse_cell)
		
		# initial build to account for single cell
		rect = Vector2i.ZERO
		
	if event.is_action_released("ui_accept"):
		emit_signal("rect_selected", anchor, rect)
		is_mouse_clicked = false
	
	if event.is_action_pressed("ui_cancel"):
		emit_signal("cell_clicked_right", mouse_cell)
	
	if event.is_action_pressed("Undo"):
		emit_signal("undo_request")
	
	

var rect: Vector2i
var anchor: Vector2i
var old_cell: Vector2i = Vector2i.ZERO
func _process(delta: float) -> void:
	var new_cell: Vector2i = UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32))
	if old_cell != new_cell and is_mouse_clicked:
		rect = new_cell - anchor
	if new_cell != old_cell:
		old_cell = new_cell
		emit_signal("mouse_cell_changed", new_cell)
	if is_mouse_held:
		emit_signal("mouse_held")

func DisableInput() -> void:
	set_process_unhandled_input(false)

func EnableInput() -> void:
	set_process_unhandled_input(true)
