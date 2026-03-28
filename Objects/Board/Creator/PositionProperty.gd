class_name PositionProperty
extends BObjectProperty

func _init(change_signal: Signal) -> void:
	super(change_signal)
	title = "Cell"

func StringifyProperty() -> String:
	return "Cell: " + str(value)
