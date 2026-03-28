class_name LevelPopup
extends Node2D

var type: int

func SetType(type: int) -> void:
	self.type = type
	match type:
		1:
			$Sprite2D.texture = load("res://Assets/Sprites/fantastic.png")
			$AudioStreamPlayer.stream = load("res://Assets/Audio/level_7.wav")
		2:
			$Sprite2D.texture = load("res://Assets/Sprites/splendid.png")
			$AudioStreamPlayer.stream = load("res://Assets/Audio/level_8.wav")
		3:
			$Sprite2D.texture = load("res://Assets/Sprites/no_way.png")
			$AudioStreamPlayer.stream = load("res://Assets/Audio/level_9.wav")
	

func _ready() -> void:
	var animation_player: AnimationPlayer = get_node("AnimationPlayer")
	animation_player.play("popup")
	animation_player.animation_finished.connect(func(_name): queue_free())
	await get_tree().create_timer(0.8).timeout
	SummonFireworks()

func SummonFireworks() -> void:
	var amount: int
	var max_cd: float
	match type:
		0:
			amount = 0
		1:
			amount = 1
		2:
			amount = 4
			max_cd = 0.15
		3:
			amount = 25
			max_cd = 0.0
	
	for cycle in amount:
		var location: Vector2 = Vector2.ZERO
		
		location.x = randi_range(-256, 256)
		location.y = randi_range(-64, 64)
		
		var firework = load("res://Objects/Effects/fireworks.tscn").instantiate()
		firework.position = location
		add_child(firework)
		await get_tree().create_timer(0.1 + randf_range(0.0, max_cd)).timeout
	
