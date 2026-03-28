extends Line2D

func _ready() -> void:
	width = 4
	add_point(Vector2(0, 0))
	add_point(Vector2(0, 0))
	
	var front: Tween = create_tween()
	var behind: Tween = create_tween()
	
	front.tween_method(UpdatePoint.bind(1), points[1], points[1] + Vector2(96, 0), 0.5)
	behind.tween_method(UpdatePoint.bind(0), points[0], points[0] + Vector2(96, 0), 0.5).set_delay(0.2)
	

func UpdatePoint(pos: Vector2, index: int) -> void:
	set_point_position(index, pos)
	
