class_name Property
extends Control

func ConnectProperty(change_signal: Signal, prop_title: String) -> void:
	get_node("HBoxContainer/Title").text = prop_title
	change_signal.connect(func(new_value: Variant) -> void:
		get_node("HBoxContainer/Value").text = str(new_value))
