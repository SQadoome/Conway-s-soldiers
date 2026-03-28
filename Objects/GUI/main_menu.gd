class_name MainMenu
extends Control

signal story()
signal browse_levels

func _ready() -> void:
	get_node("VBoxContainer/Standard").pressed.connect(emit_signal.bind("story"))
	get_node("VBoxContainer/LevelBrowser").pressed.connect(emit_signal.bind("browse_levels"))

func _on_depart_pressed() -> void:
	get_tree().quit()
