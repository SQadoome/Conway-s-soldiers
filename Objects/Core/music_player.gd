class_name MusicPlayer
extends AudioStreamPlayer

@onready var TIMER: Timer = Timer.new();

const STREAMS: Array[AudioStream] = [
	preload("res://Assets/Audio/Music/penroses_patterns.mp3"),
	preload("res://Assets/Audio/Music/firefly_in_a_fairytale.mp3"),
];

func _ready() -> void:
	bus = &"music";
	finished.connect(changeSong);
	changeSong();
	
	TIMER.wait_time = 5.0;
	TIMER.one_shot = true;
	add_child(TIMER);
	TIMER.timeout.connect(func(): 
		animateSong()
		TIMER.wait_time = 5 + randi_range(0, 5);
	);
	TIMER.start();

func animateSong() -> void:
	var new_tween: Tween = get_tree().create_tween();
	var offset: int = randi_range(-1, 1);
	
	new_tween.tween_property(self, "pitch_scale", 1 + offset/10.0, 4.0);
	new_tween.finished.connect(func(): 
		new_tween.kill();
		TIMER.start();
	);


func changeSong() -> void:
	stream = STREAMS[randi_range(0, STREAMS.size() - 1)];
	play();
	
