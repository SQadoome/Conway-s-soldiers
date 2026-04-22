class_name GameHandler
extends Node2D

var focuses: Dictionary[Vector2i, FocusedLocation] = {}
var rules: Dictionary
var level_data: LevelData
@export var board: IngameBoard

func _enter_tree() -> void:
	board.level_data = level_data
	

func _ready() -> void:
	$GUI/StartPopup.Animate()
	$CanvasLayer/BoxTile._rotate(UTIL.DIRECTIONS.RIGHT)
	$CanvasLayer/BoxTile.move(UTIL.CellurizeVector($CanvasLayer/BoxTile.position))
	GameEvents.ingame_board_eventer.soldier_moved.connect(GeneratePopup)
	GameEvents.ingame_board_eventer.finish.connect(
		func():
			var tween: Tween = create_tween()
			tween.tween_property($GUI/ColorRect, "color", Color(1.0, 1.0, 1.0, 1.0), 2.0)
			tween.finished.connect(
				func():
					await get_tree().create_timer(1.0).timeout
					GameEvents.ingame_board_eventer.emit_signal("leave")
			)
	)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Highlight"):
		var cell: Vector2i = vec_to_cell(get_global_mouse_position() + Vector2(32, 32))
		
		if not focuses.has(cell):
			var focus: FocusedLocation = load("res://Objects/Board/Objects/focused_location.tscn").instantiate()
			focus.position = cell*64
			focuses[cell] = focus
			$CanvasLayer.add_child(focus)
		else:
			focuses[cell].queue_free()
			focuses.erase(cell)
		
	

func vec_to_cell(at_pos: Vector2) -> Vector2i:
	return Vector2i(floori(at_pos.x/64.0), floori(at_pos.y/64.0))
	

func CreatePopup(at_cell: Vector2i, type: int) -> LevelPopup:
	var popup: LevelPopup = load("res://Objects/Effects/level_popup.tscn").instantiate()
	popup.position = at_cell*64
	popup.SetType(type)
	$CanvasLayer.add_child(popup)
	return popup

func GeneratePopup(m: Move) -> void:
	var at_cell: Vector2i = m.target_location
	
	
	if at_cell.y == -7:
		var popup: LevelPopup = CreatePopup(at_cell, 1)
	elif at_cell.y == -8:
		var popup: LevelPopup = CreatePopup(at_cell, 2)
	elif at_cell.y < -9:
		var popup: LevelPopup = CreatePopup(at_cell, 3)
	
