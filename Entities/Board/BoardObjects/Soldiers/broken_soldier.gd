class_name BrokenSoldier
extends Node2D

func _ready() -> void:
	animateBreaking()

func animateBreaking() -> void:
	animatePieces()
	animateSelf()
	

func animatePieces() -> void:
	for piece in get_node("Pieces").get_children():
		var animator = get_tree().create_tween()
		var dir = -sign(piece.position.x)
		var angle = randf_range(0, (PI/2.0)*dir)
		var animator_property = animator.parallel().tween_property(piece, "rotation", angle, 2.0)
		var destination = piece.global_position.y + 1080*4
		animator_property.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		animator_property = animator.parallel().tween_property(piece, "position:y", destination, 2.0)
		animator_property.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		animator.finished.connect(func(): 
			animator.kill()
			queue_free())
	

func animateSelf() -> void:
	await get_tree().create_timer(1.5).timeout
	var visibilty_tween = get_tree().create_tween()
	visibilty_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.45)
	visibilty_tween.finished.connect(visibilty_tween.kill)
	
