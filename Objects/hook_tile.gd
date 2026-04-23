class_name HookTile
extends Node2D

signal reset
signal hide_static_soldier
var quick: bool = false

func HookBreakOut(quick: bool) -> void:
	var animator: AnimationPlayer = get_node("AnimationPlayer")
	self.quick = quick
	if quick:
		_on_breakout_timeout()
	else:
		animator.play("crack")
		$Breakout.start()

func _on_breakout_timeout() -> void:
	$CPUParticles2D.emitting = true
	$Cracks.visible = false
	$Hole.visible = true
	CreateHook()
	var particles: CPUParticles2D = load("res://cpu_particles_2d.tscn").instantiate()
	add_child(particles)
	particles.emitting = false
	particles.finished.connect(func():
		particles.queue_free())


const HOOK: PackedScene = preload("res://Objects/Effects/ascend_hook.tscn")
func CreateHook() -> void:
	var hook: AscendHook = HOOK.instantiate()
	reset.connect(hook.queue_free)
	hook.SetUp(UTIL.cellurize_vector(position) + Vector2i(0, 7), quick)
	hook.soldier_got_hooked.connect(emit_signal.bind("hide_static_soldier"))
	add_child(hook)

func Reset() -> void:
	get_node("AnimationPlayer").play("RESET")
	emit_signal("reset")
	$Hole.visible = false
	$Cracks.visible = true
	$Breakout.stop()
