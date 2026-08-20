class_name AnimatedSoldier
extends AnimatedObject


func _ready() -> void:
	pass
	

func animate(query: AnimationObjectQuery) -> void:
	var from_pos: Vector2 = TileUtil.vectorize_cell(query.from);
	var to_pos: Vector2 = TileUtil.vectorize_cell(query.to);
	
	position = from_pos;
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT);
	tween.tween_property(self, ^"position", to_pos, 0.3);
	
	var _on_finish := func() -> void:
		tween.kill()
		finished.emit()
		queue_free();
	
	tween.finished.connect(_on_finish);
	
