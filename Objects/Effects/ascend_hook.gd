class_name AscendHook
extends Node2D

signal soldier_got_hooked

var tile: Vector2i

@export var line: Line2D
@export var hooked_soldier: Sprite2D
@export var hook: Sprite2D
@export var abductor: Node2D

func _ready() -> void:
	if randi_range(1, 2) == 1:
		scale.x = -1
		hooked_soldier.scale.x = -0.5
	hooked_soldier.material.set_shader_parameter(
		"influence",
		(UTIL.CellurizeVector(hooked_soldier.global_position).y + 7)/100.0
	)
	Activate()

func HookSoldier() -> void:
	hooked_soldier.visible = true
	emit_signal("soldier_got_hooked")

func Activate() -> void:
	abductor.visible = true
	Drop()

var quick: bool
func SetUp(tile: Vector2i, quick: bool = false) -> AscendHook:
	self.quick = quick
	self.tile = tile
	return self

func Drop() -> void:
	PlayAudio(load("res://Assets/Audio/hook_fast_pull.wav"), 0.0, 0.95)
	var target: int = tile.y - UTIL.CellurizeVector(global_position).y
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(abductor, "rotation_degrees", 25, 0.3)
	tween.set_trans(Tween.TRANS_QUAD).tween_property(abductor, "rotation_degrees", 0, 0.7).set_delay(0.2)
	tween.set_ease(Tween.EASE_OUT).tween_property(abductor, "rotation_degrees", -18, 0.6)
	
	tween.finished.connect(ContinuosTilt)
	
	Expand(6).finished.connect(
		func():
			Retreat(quick)
			HookSoldier())

var values: PackedInt32Array = [17, -16, 14, -12, 10, 8]
func ContinuosTilt() -> void:
	for value:int in values:
		await Tilt(value, 1.3).finished
	

func PlayAudio(stream: AudioStream, delay: float = 0.0, pitch: float = 1.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	
	$AudioStreamPlayer2D.stream = stream
	$AudioStreamPlayer2D.pitch_scale = pitch
	$AudioStreamPlayer2D.play()

func Retreat(quick: bool, cycles: int = 3) -> void:
	if not quick:
		PlayAudio(load("res://Assets/Audio/hook_slow_pull.wav"), 1.2)
		for cycle:int in cycles:
			await get_tree().create_timer(1.2).timeout
			
			var simple_shake: Callable = func(direction: int) -> Signal:
				var tween: Tween = create_tween()
				tween.tween_property(
					abductor, "position",
					abductor.position + Vector2(0, 7*direction), 0.1
				)
				return tween.finished
			
			Shrink(1).finished.connect(simple_shake.bind(1))
	
	var time_1: float = 2.0
	var time_2: float = 0.5
	var time_3: float = 0.3
	
	if quick:
		time_1 = 0.5
		time_2 = 0.3
		time_3 = 0.2
	
	await get_tree().create_timer(time_1).timeout
	PlayAudio(load("res://Assets/Audio/hook_fast_pull.wav"), 0.0, 1.2)
	
	# quick finish
	Shrink(7 - (cycles), time_2, Tween.EASE_IN)
	
	await get_tree().create_timer(time_3).timeout
	var scale_tween: Tween = create_tween()
	scale_tween.finished.connect(func():
		scale_tween.kill()
		if quick:
			GameEvents.ingame_board_eventer.emit_signal("finish")
		)
	scale_tween.tween_property(abductor, "scale", Vector2(0, 0), 0.3)

func Expand(tiles: int, duration: float = 1.2) -> Tween:
	var expand: Callable = func(new_pos: Vector2) -> void:
		line.set_point_position(0, new_pos)
		hook.position = new_pos + Vector2(-4, 38)
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_method(
		expand, line.points[0],
		line.points[0] + Vector2(0, tiles*64), duration
	)
	tween.finished.connect(tween.kill)
	return tween

func Shrink(tiles: int, duration: float = 0.3, ease: Tween.EaseType = Tween.EASE_OUT) -> Tween:
	var expand: Callable = func(new_pos: Vector2) -> void:
		line.set_point_position(0, new_pos)
		hook.position = new_pos + Vector2(-4, 38)
	
	var tween: Tween = create_tween().set_ease(ease)
	tween.tween_method(
		expand, line.points[0],
		line.points[0] + Vector2(0, -tiles*64), duration
	)
	tween.finished.connect(tween.kill)
	return tween

func Tilt(amount: int, duration: float) -> Tween:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		abductor, "rotation_degrees",
		amount, duration
	)
	tween.finished.connect(tween.kill)
	return tween
