class_name Impulsive
extends RefCounted

signal impulsed(impulse_value: Variant)

func connect_impulse(change_signal: Signal) -> Impulsive:
	change_signal.connect(Impulse)
	return self

func Impulse(value: Variant = "") -> void:
	assert(not value == null, "No value of impulsive")
	emit_signal("impulsed", value)
