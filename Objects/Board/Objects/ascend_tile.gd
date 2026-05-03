class_name AscendTile
extends Node2D

var ascended: bool = false

var color_tween: Tween
var shine_tween: Tween

var tile: Vector2i
var count_on: bool = false
var move_count: int = 0
var held_soldier: bool = false

@export var hook_tile: HookTile
@export var soldier_sprite: Sprite2D
@export var activation_detector: ActivationDetector

func _enter_tree() -> void:
	tile = UTIL.cellurize_vector(position)
	GameEvents.ingame_board_eventer.undo_soldier_move.connect(OnUndoSoldierMove)
	

func _ready() -> void:
	activation_detector.activated.connect(_on_soldier_detected)
	activation_detector.set_tile(UTIL.cellurize_vector(global_position))
	
	hook_tile.position.y = -7*64
	hook_tile.visible = true
	hook_tile.hide_static_soldier.connect(func(): $Soldier.visible = false)
	soldier_sprite.material.set_shader_parameter(
		"influence", UTIL.cellurize_vector(position).y/100.0
	)
	

func _on_soldier_detected(m: Move) -> void:
	if not ascended:
		count_on = true
		Ascend()
		GameEvents.ingame_board_eventer.ascension.emit(
			IngameBoardEventer.Ascension.new(
				m.target_location,
				UTIL.cellurize_vector(hook_tile.global_position))
		)
	if count_on:
		move_count += 1
	

func OnUndoSoldierMove(d: IngameBoardEventer.UndoSoldierMove) -> void:
	if count_on:
		move_count -= 1
		assert(!move_count < 0, "HOW THE FUCK DID IT SKIP ASCENDING MOVE")
		if move_count == 0:
			UnAscend()

func Ascend() -> void:
	IngameBoard.ascension_count += 1
	var quick = IngameBoard.ascension_count >= IngameBoard.total_ascensions
	
	var soldier_exists: bool = GameEvents.ingame_board_eventer.request_data(
		IngameBoardEventer.DATA_REQUESTS.DOES_SOLDIER_EXIST, UTIL.cellurize_vector(hook_tile.global_position)
	)
	if soldier_exists:
		held_soldier = true
	
	hook_tile.HookBreakOut(quick)
	soldier_sprite.visible = true
	ascended = true
	color_tween = create_tween()
	shine_tween = create_tween()
	color_tween.tween_property(
		get_node("Tile"),
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		0.5
	)
	shine_tween.tween_property(
		get_node("Shine"),
		"modulate",
		Color(1.0, 1.0, 1.0, 1.0),
		0.5
	)
	color_tween.finished.connect(func():
		color_tween.kill()
		shine_tween.kill())
	

func UnAscend() -> void:
	IngameBoard.ascension_count -= 1
	if color_tween.is_running():
		color_tween.stop()
		shine_tween.stop()
		color_tween.kill()
		shine_tween.kill()
	
	soldier_sprite.visible = false
	hook_tile.Reset()
	get_node("Shine").modulate = Color(1.0, 1.0, 1.0, 0.0)
	get_node("Tile").modulate = Color8(200, 200, 200, 255)
	ascended = false
	count_on = false
	
	if held_soldier:
		GameEvents.ingame_board_eventer.emit_signal(
			"request_place_soldier",
			UTIL.cellurize_vector(hook_tile.global_position)
		)
		GameEvents.ingame_board_eventer.emit_signal(
			"request_remove_soldier",
			UTIL.cellurize_vector(hook_tile.global_position) + Vector2i.UP
		)
		held_soldier = false
