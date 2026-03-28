class_name CreatorBoard
extends Board

@export var OBJECTS: TileMapLayer

var paint_object: String
var level_data: Dictionary = {}
var objects_data: Dictionary = {}

func _enter_tree() -> void:
	GameEvents.gui_eventer.object_menu_object_selected.connect(ChangePaintObject)
	GameEvents.creator_board_eventer.game_rule_changed.connect(ChangeGameRule)
	GameEvents.creator_board_eventer.save.connect(Save)

func _ready() -> void:
	super()
	input_listener.rect_selected.connect(func(from: Vector2i, rect: Vector2i):
		for loc:Vector2i in BuildRect(from, rect):
			if OBJECTS.get_cell_source_id(loc) == -1:
				PlaceObject(paint_object, loc)
	)
	add_child(Line.new(CAMERA.camera_shifted))

func Save() -> void:
	level_data["objects"] = objects_data
	LevelSaver.Save(level_data)

func ChangeGameRule(key: String, value: Variant) -> void:
	level_data[key] = value
	print(level_data)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if DoesObjectOnMouseExist():
			RemoveObject(UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32)))

func DoesObjectOnMouseExist() -> bool:
	var cell: Vector2i = UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32))
	var id: int = OBJECTS.get_cell_source_id(cell)
	return (not (id == -1))

func ChangePaintObject(obj_name: String) -> void:
	paint_object = obj_name

func BuildRect(from: Vector2i, rect_size: Vector2i) -> PackedVector2Array:
	var arr: PackedVector2Array = []
	arr.resize(abs(rect_size.x*rect_size.y))
	
	for x:int in get_range(rect_size.x):
		for y:int in get_range(rect_size.y):
			arr.append(Vector2i(x, y) + from)
	
	return arr

func get_range(size: int) -> PackedInt32Array:
	var arr: PackedInt32Array = [0]
	
	if size > 0:
		arr = range(0, size + 1)
	
	if size < 0:
		arr = range(size, 1)
	
	return arr

func RemoveObject(at_cell: Vector2i) -> void:
	assert(
		objects_data.has(at_cell),
		"No object exists!")
	
	objects_data.erase(at_cell)
	OBJECTS.erase_cell(at_cell)

func PlaceObject(object_name: String, at_cell: Vector2i) -> void:
	assert(
		not objects_data.has(at_cell),
		"There is already an object at cell")
	var id: int = 0
	
	objects_data[at_cell] = object_name
	
	match object_name:
		"soldier":
			id = 0
		"ascension":
			id = 1
		_:
			assert(false, "No object with name: " + str(object_name))
	
	OBJECTS.set_cell(at_cell, 0, Vector2i(id, 0))
