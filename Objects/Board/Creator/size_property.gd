class_name SizeProperty
extends BObjectProperty

func _init(change_signal: Signal) -> void:
	super(change_signal)
	title = "Size"

func StringifyProperty() -> String:
	return "Size: " + str(value)
