class_name BoardObject
extends Node2D

signal cell_changed(new_cell: Vector2i)
signal size_changed(new_size: Vector2)
signal name_changed(new_name: String)

var properties_holder: PropertiesHolder
var object_name: String
var size: Vector2

func _ready() -> void:
	properties_holder = load("res://Objects/GUI/properties.tscn").instantiate()
	add_child(properties_holder)
	properties_holder.global_position = global_position + Vector2(64, 0)

# Override
func SetCell(new_cell: Vector2i) -> void:
	position = new_cell*64
	emit_signal("cell_changed", new_cell)

func SetSize(size: Vector2) -> void:
	self.size = size

func SetName(object_name: String) -> void:
	self.object_name = object_name
	emit_signal("name_changed", object_name)
