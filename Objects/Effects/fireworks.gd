extends Node2D

func _ready() -> void:
	var count = 30
	var color: Color = GetColor(randi_range(1, 3))
	for i:Line2D in get_children():
		i.rotation_degrees = count
		i.modulate = color
		count += 30
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
	

func GetColor(index: int) -> Color:
	match index:
		1:
			return Color.RED
		2:
			return Color.BLUE
		3:
			return Color.GREEN
	return Color.WHITE
