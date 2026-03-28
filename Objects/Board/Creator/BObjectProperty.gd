class_name BObjectProperty
extends Resource

signal property_changed(value: Variant)

var title: String
var value: Variant:
	set(value):
		value = value
		emit_signal("property_changed", value)

func _init(change_signal: Signal) -> void:
	change_signal.connect(func(new_value: Variant): value = new_value)

# Override pls
func StringifyValue() -> String:
	return str(value)
