class_name AscendTile
extends Node2D

var ascended: bool = false

var color_tween: Tween
var shine_tween: Tween

var tile: Vector2i
var count_on: bool = false
var move_count: int = 0
var held_soldier: bool = false

@onready var HOOK_TILE: HookTile = get_node("HookTile")
@onready var SOLDIER: Sprite2D = get_node("Soldier")

func _ready() -> void:
	tile = UTIL.CellurizeVector(position)
	GameEvents.ingame_board_eventer.soldier_moved.connect(OnSoldierMove)
	GameEvents.ingame_board_eventer.undo_soldier_move.connect(OnUndoSoldierMove)
	HOOK_TILE.position.y = -7*64
	HOOK_TILE.visible = true
	HOOK_TILE.hide_static_soldier.connect(func(): $Soldier.visible = false)
	SOLDIER.material.set_shader_parameter(
		"influence", UTIL.CellurizeVector(position).y/100.0)
	

func OnSoldierMove(m: Move) -> void:
	if m.target_location == tile and not ascended:
		count_on = true
		Ascend()
		GameEvents.ingame_board_eventer.ascension.emit(
			IngameBoardEventer.Ascension.new(
				m.target_location,
				UTIL.CellurizeVector(HOOK_TILE.global_position))
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
		IngameBoardEventer.DATA_REQUESTS.DOES_SOLDIER_EXIST, UTIL.CellurizeVector(HOOK_TILE.global_position)
	)
	if soldier_exists:
		held_soldier = true
	
	HOOK_TILE.HookBreakOut(quick)
	SOLDIER.visible = true
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
	
	SOLDIER.visible = false
	HOOK_TILE.Reset()
	get_node("Shine").modulate = Color(1.0, 1.0, 1.0, 0.0)
	get_node("Tile").modulate = Color8(200, 200, 200, 255)
	ascended = false
	count_on = false
	
	if held_soldier:
		GameEvents.ingame_board_eventer.emit_signal(
			"request_place_soldier",
			UTIL.CellurizeVector(HOOK_TILE.global_position)
		)
		GameEvents.ingame_board_eventer.emit_signal(
			"request_remove_soldier",
			UTIL.CellurizeVector(HOOK_TILE.global_position) + Vector2i.UP
		)
		held_soldier = false
