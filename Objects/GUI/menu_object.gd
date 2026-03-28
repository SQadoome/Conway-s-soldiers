class_name MenuObject
extends Control

signal selected(obj: MenuObject)

@export var sprite: Texture
@export var object_name: String

func _ready() -> void:
	get_node("TextureRect").texture = sprite
	get_node("Button").pressed.connect(func(): emit_signal("selected", self))

func SimulateSelection() -> void:
	emit_signal("selected", self)
