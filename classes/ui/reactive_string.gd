class_name ReactiveString
extends Reactive

var state: String:
	set(new_state):
		state = new_state
		emit_signal("react")
