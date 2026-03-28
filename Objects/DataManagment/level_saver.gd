class_name LevelSaver
extends Resource

static func Save(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open("res://Levels/level_1.level", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
