class_name LevelHolder
extends Control

var path_name: String
var data: LevelData

signal level_chosen(data: LevelData)

func _ready() -> void:
	$Button.pressed.connect(emit_signal.bind("level_chosen", data))

func SetLevel(level_path: String) -> void:
	data = LevelReader.ReadLevel(level_path)
	
	$Button.text = data.level_name
