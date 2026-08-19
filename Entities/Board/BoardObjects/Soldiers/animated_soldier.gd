class_name AnimatedSoldier
extends AnimatedObject

var is_running: bool = false

func _ready() -> void:
	pass
	

func animate(query: AnimationObjectQuery) -> void:
	var from_pos: Vector2 = TileUtil.vectorize_cell(query.from);
	var to_pos: Vector2 = TileUtil.vectorize_cell(query.to);
	
	position = from_pos;
	is_running = true;
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT);
	tween.tween_property(self, ^"position", to_pos, 0.3);
	tween.finished.connect(finished.emit);
	tween.finished.connect(func() -> void:
		is_running = false
		tween.kill()
		_on_finish);
	

func _on_finish() -> void:
	finished.emit();
	queue_free();
	
