extends Node2D

@onready var MENU: MainMenu
@export var level_selector: LevelSelector
var game_handler: GameHandler

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_screen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	

func _ready() -> void:
	GameEvents.gui_eventer.back.connect(func():
		level_selector.hide()
		MENU.show())
	level_selector.hide()
	level_selector.new_game.connect(func(d:LevelData):
		NewGame(d)
		level_selector.hide()
	)
	MENU = get_node("CanvasLayer/MainMenu")
	MENU.story.connect(func():
		MENU.hide()
		level_selector.show()
	)
	MENU.browse_levels.connect(func():
		MENU.hide()
		var browser: CreatorBoard = load("res://Objects/Board/Creator/creator_board.tscn").instantiate()
		add_child(browser)
		)
	GameEvents.ingame_board_eventer.leave.connect(
		func():
			game_handler.queue_free()
			level_selector.show()
	)

func NewGame(level_data: LevelData) -> void:
	game_handler= load("res://Objects/Core/game_handler.tscn").instantiate()
	game_handler.level_data = level_data
	add_child(game_handler)
