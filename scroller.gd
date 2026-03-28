@tool
class_name Scroller
extends Control

enum modes{
	VERTICAL,
	HORIZONTAL
}
@export var mode: modes = modes.VERTICAL

var children: Array[Control] = []
var mouse_in: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and mouse_in:
			pass
		
	

func _ready() -> void:
	mouse_entered.connect(func(): mouse_in = true)
	mouse_exited.connect(func(): mouse_in = false)
	children.resize(get_child_count())
	for c in get_children():
		assert(c is Control, "Scroller only accepts controls as children")
		children.append(c)
