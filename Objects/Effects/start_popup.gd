extends Control

func _ready() -> void:
	$Label.position.y += 1000
	$Delay.timeout.connect(_on_delay)

func Animate() -> void:
	get_node("AnimationPlayer").play("d")
	var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	pos_tween.finished.connect(pos_tween.kill)
	$Delay.wait_time = 1.8
	$Delay.start()
	pos_tween.tween_property($Label, "position", $Label.position - Vector2(0, 1000), 1.2)

func _on_delay() -> void:
	var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	pos_tween.finished.connect(func():
		pos_tween.kill()
		queue_free())
	pos_tween.tween_property($Label, "position", $Label.position + Vector2(0, 1000), 1.2)
