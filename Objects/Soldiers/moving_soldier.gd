class_name MovingSoldier
extends Node2D

signal finished

var destination: Vector2

func _ready() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(update, position, destination, 0.3)
	tween.finished.connect(func():
		finished.emit()
		tween.kill()
		queue_free())
	get_node("Sprite2D").material.set_shader_parameter("influence", 0)

func set_properties(from: Vector2, to: Vector2) -> void:
	position = from
	destination = to

func update(new_pos: Vector2) -> void:
	position = new_pos
	if UTIL.cellurize_vector(new_pos).y < 0:
		get_node("Sprite2D").material.set_shader_parameter("influence", new_pos.y/6400)
	
