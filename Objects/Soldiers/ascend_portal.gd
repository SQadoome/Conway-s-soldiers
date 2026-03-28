class_name AscendPortal
extends Node2D

static var portals: Array[AscendPortal] = []

signal reveal_animation_finished
var is_revealing: bool = true

## returns true if there exists a portal that can handle the requested hook
static func RequestHookGeneration(tile: Vector2i, placer: Node2D) -> void:
	var portal: AscendPortal = IsTherePortalToHoldHook(tile)
	if portal != null:
		portal.QueueHook(tile)
	else:
		GeneratePortal(tile, placer).QueueHook(tile)

static func IsTherePortalToHoldHook(at_cell: Vector2i) -> AscendPortal:
	var cells: PackedVector2Array = [
		Vector2(-1, -1),Vector2(0, -1),Vector2(1, -1),
		Vector2(-1, 0),Vector2(0, 0),Vector2(1, 0),
		Vector2(-1, 1),Vector2(0, 1),Vector2(1, 1)
	]
	for portal:AscendPortal in portals:
		var portal_cell: Vector2i = UTIL.CellurizeVector(portal.global_position)
		if cells.has(at_cell - portal_cell - Vector2i(0, portal_y_offset)):
			return portal
	return null

static func GeneratePortal(at_cell: Vector2i, placer: Node2D) -> AscendPortal:
	var portal: AscendPortal = load("res://Objects/Soldiers/ascend_portal.tscn").instantiate()
	portal.position = at_cell*64 - Vector2i(0, portal_y_offset*64)
	placer.add_child(portal)
	return portal

const portal_y_offset: int = 9

func _ready() -> void:
	Reveal()

## queues a hook for placing
func QueueHook(target: Vector2i) -> void:
	var hook: AscendHook = GenerateHook(target)
	if is_revealing:
		reveal_animation_finished.connect(hook.Activate)
	else:
		hook.Activate()

const HOOK: PackedScene = preload("res://Objects/Effects/ascend_hook.tscn")
func GenerateHook(target: Vector2i) -> AscendHook:
	var hook: AscendHook = HOOK.instantiate().SetUp(target)
	get_node("Portal/Hooks").add_child(hook)
	return hook

func AnimatePortal(from: float, to: float) -> Signal:
	var tween: Tween = create_tween()
	tween.tween_method(
		func(percentage: float): $Portal/Body.material.set_shader_parameter("percentage", percentage),
		from,
		to,
		2.0).set_ease(Tween.EASE_OUT)
	tween.finished.connect(tween.kill)
	return tween.finished

## kills this portal making it unable to handle hook requests freeing it at the end
func Dissolve() -> void:
	portals.erase(self)
	AnimatePortal(1.0, 0.0).connect(queue_free)

## adds portal to handle hook requests after animation
func Reveal() -> void:
	AnimatePortal(0.0, 1.0).connect(func():
		portals.append(self)
		is_revealing = false
		get_node("Portal/Shadow").visible = true
		emit_signal("reveal_animation_finished"))

#region
#@onready var STRUCTURE: Node2D = get_node("Structure")
#@onready var STREAMER: AudioStreamPlayer2D = get_node("Streamer1")
#
#func _ready() -> void:
	#if randi_range(0, 1) == 1:
		#STRUCTURE.scale.x = -1
		#$Structure/Abducter/Line2D/Hook/HookedSoldier.scale.x = -0.5
	#
	#var influence: float = UTIL.CellurizeVector(position).y/100.0
	#$TempSoldier.material.set_shader_parameter("influence", influence)
	#$Structure/Abducter/Line2D/Hook/HookedSoldier.material.set_shader_parameter("influence", influence)
	#
	#STRUCTURE.hide()
	#STREAMER.stream = load("res://Assets/Audio/portal_open.wav")
	#STREAMER.play()
	#$Portal/Glow.modulate = Color(1, 1, 1, 0)
	#RevealPortal().connect(func():
		#GlowPortal().connect(func():
			#$Portal/Shadow.show()
			#AnimateHook()
			#STRUCTURE.show()
		#))
	#
#
#func _process(delta: float) -> void:
	#if %HookGrab.global_position.distance_to($TempSoldier.global_position) <= 25:
		#GrabSoldier()
	#
#
#func GrabSoldier() -> void:
	#$TempSoldier.visible = false
	#$Structure/Abducter/Line2D/Hook/HookedSoldier.global_position = $%HookGrab.global_position
	#$Structure/Abducter/Line2D/Hook/HookedSoldier.visible = true
	#set_process(false)
#
#func Setup(cell: Vector2i) -> void:
	#position = cell*64
	#$Structure/Abducter.position.y = -height*64
	#get_node("TempSoldier").global_position = position
	#$Portal.position.y = -height*64 + 32
	#$Portal.visible = true
#
#func AnimatePortal(from: float, to: float) -> Signal:
	#var tween: Tween = create_tween()
	#tween.tween_method(
		#func(percentage: float): $Portal/Body.material.set_shader_parameter("percentage", percentage),
		#from,
		#to,
		#2.0).set_ease(Tween.EASE_OUT)
	#tween.finished.connect(tween.kill)
	#return tween.finished
#
#func RevealPortal() -> Signal:
	#return AnimatePortal(0.0, 1.0)
#
#func DissolvePortal() -> Signal:
	#return AnimatePortal(1.0, 0.0)
#
#func GlowPortal() -> Signal:
	#var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	#tween.tween_property($Portal/Glow, "modulate", Color8(255, 255, 255, 255), 0.7)
	#tween.finished.connect(tween.kill)
	#return tween.finished
#
#func DarkenPortal() -> Signal:
	#var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	#tween.tween_property($Portal/Glow, "modulate", Color8(255, 255, 255, 0), 0.7)
	#tween.finished.connect(tween.kill)
	#return tween.finished
#
#func ColorizeSoldier() -> void:
	#$TempSoldier.material.set_shader_parameter(
		#"influence",
		#UTIL.CellurizeVector(position).y/100.0
	#)
#
#func AnimateHook() -> void:
	#AnimateDrop()
#
#var height: int = 12
#func AnimateDrop() -> void:
	#$Animator.play("drop")
	#var tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	#tween.tween_method(ExpandLine, LINE.points[1], LINE.points[1] + Vector2(0, (height)*64), 1.2)
	#tween.finished.connect(func():
		#AnimateRetreat()
		#tween.kill()
		#await get_tree().create_timer(1.0).timeout
		#STREAMER.stream = load("res://Assets/Audio/hook_slow_pull.wav")
		#STREAMER.play())
#
#@onready var LINE: Line2D = get_node("Structure/Abducter/Line2D")
#@onready var HOOK: Sprite2D = get_node("Structure/Abducter/Line2D/Hook")
#func ExpandLine(new_pos: Vector2) -> void:
	#LINE.set_point_position(1, -new_pos)
	#LINE.position = new_pos
#
#func ShrinkLine(new_pos: Vector2) -> void:
	#LINE.set_point_position(1, new_pos)
	#LINE.position = -new_pos
#
#func AnimateRetreat(cycles: int = 3) -> void:
	#if cycles <= 0:
		#var tween: Tween = create_tween()
		#tween.tween_method(
			#ShrinkLine,
			#LINE.points[1],
			#LINE.points[1] + Vector2(0, (height*64)-(3*96)),
			#0.7).set_delay(1.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		#tween.finished.connect(func():
			#LINE.points[1] = Vector2.ZERO
			#$Animator.play("retreat_finish")
			#tween.kill()
			#$Animator.animation_finished.connect(func(_name: String):
				#DarkenPortal().connect(func():
					#DissolvePortal().connect(queue_free))))
		#await get_tree().create_timer(1.4).timeout
		#$Streamer1.stream = load("res://Assets/Audio/hook_fast_pull.wav")
		#$Streamer1.play()
		#return
	#
	#var tween: Tween = create_tween()
	#tween.tween_method(
		#ShrinkLine,
		#LINE.points[1],
		#LINE.points[1] + Vector2(0, 96),
		#0.3).set_delay(1.0).set_ease(Tween.EASE_OUT)
	#tween.finished.connect(func():
		#AnimateRetreat(cycles - 1)
		#tween.kill()
		#$Shaker.play("shake"))
#
#func HookSoldier() -> void:
	#get_node("Sprite2D").queue_free()
	#var soldier: Sprite2D = Sprite2D.new()
	#soldier.texture = load("res://Assets/Sprites/Soldier.png")
	#soldier.scale = Vector2(0.5, 0.5)
	#soldier.position = Vector2(16, 32)
	#get_node("Structure/Abducter/Line2D/Hook").add_child(soldier)
#endregion
