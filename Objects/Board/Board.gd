class_name Board
extends Node2D

@export var CAMERA: SmartCamera
@onready var input_listener: BoardInput = BoardInput.new()
var background: Node2D

func _ready() -> void:
	CAMERA.camera_shifted.connect(ShiftBackground)
	add_child(input_listener)
	background = Node2D.new()
	for x in range(0, 35):
		for y in range(-16, 16):
			CreateBGTile(Vector2(-x, y))
			CreateBGTile(Vector2(x, y))
	add_child(background)

func ShiftBackground(new_cell: Vector2i) -> void:
	background.position = Vector2(new_cell*64)


const TILES: Texture = preload("res://Assets/Sprites/levels_grid.png")
func CreateBGTile(at_cell: Vector2) -> void:
	var bg_tile: Sprite2D = Sprite2D.new()
	bg_tile.texture = TILES
	bg_tile.hframes = 9
	bg_tile.frame = 8
	bg_tile.scale = Vector2(0.5, 0.5)
	bg_tile.position = at_cell*64
	bg_tile.z_index = -1
	background.add_child(bg_tile)
