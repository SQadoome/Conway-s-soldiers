extends Control

enum states {
	ON, OFF
}

var state: states = states.ON
var is_folding: bool = false

func _ready() -> void:
	GameEvents.gui_eventer.object_menu_fold_transition_started.connect(
		func(): is_folding = true
	)
	GameEvents.gui_eventer.object_menu_fold_transition_finished.connect(
		func(): is_folding = false
	)
	mouse_entered.connect(MouseEntered)

func MouseEntered() -> void:
	if is_folding:
		return
	
	if state == states.ON:
		state = states.OFF
		GameEvents.gui_eventer.emit_signal("object_menu_fold_request")
	else:
		GameEvents.gui_eventer.emit_signal("object_menu_unfold_request")
		state = states.ON
