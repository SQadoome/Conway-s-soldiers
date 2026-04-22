class_name GhostSoldier
extends Node2D

signal chosen(move: Move)

var data: Move
var rect: Rect2

func SetProperties(move: Move) -> void:
	data = move
	position = move.target_location*64
	rect = Rect2((position - Vector2(32, 32)), Vector2(64, 64))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		
		if rect.has_point(get_global_mouse_position()):
			Select()
	

func Select() -> void:
	var cell: Vector2i = Vector2(floori(position.x/64.0), floori(position.y/64.0))
	emit_signal("chosen", data)
	queue_free()
