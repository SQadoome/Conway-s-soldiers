class_name Soldier
extends Sprite2D

func _enter_tree() -> void:
	material = material.duplicate()
	set_shader_influence(0.0)

func set_shader_influence(new_value: float) -> void:
	material.set_shader_parameter("influence", new_value)
