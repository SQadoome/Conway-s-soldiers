class_name RectDrawer
extends Node2D

var rects: Array[Rect2] = []

func draw(_rects: Array[Rect2]) -> void:
	rects = _rects
	

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for rect:Rect2 in rects:
		draw_rect(Rect2(rect.position*64 - Vector2(32, 32), rect.size*64), Color.YELLOW, false, 8.0)
	

func flush() -> void:
	for i:Node in get_children():
		i.queue_free()
		
	
