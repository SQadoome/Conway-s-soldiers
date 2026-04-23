class_name CreatorBoard
extends Board

@export var OBJECTS: TileMapLayer
@export var input_listener: BoardInput
@export var line: Line

var paint_object: String
var level_data: Dictionary = {}
var objects_data: Dictionary = {}

func _enter_tree() -> void:
	GameEvents.gui_eventer.object_menu_object_selected.connect(ChangePaintObject)
	GameEvents.creator_board_eventer.game_rule_changed.connect(ChangeGameRule)
	GameEvents.creator_board_eventer.save.connect(Save)

func _ready() -> void:
	input_listener.rect_selected.connect(func(from: Vector2i, rect: Vector2i):
		for loc:Vector2i in BuildRect(from, rect):
			if OBJECTS.get_cell_source_id(loc) == -1:
				PlaceObject(paint_object, loc)
	)
	

var board_rect: Rect2 = Rect2()

func is_occupied(at_cell: Vector2i) -> bool:
	return OBJECTS.get_cell_source_id(at_cell) == -1

func Save() -> void:
	var top_right: Vector2 = Vector2(
		board_rect.position.x + board_rect.size.x, board_rect.position.y
	)
	var top_left: Vector2 = Vector2(
		board_rect.position.x, board_rect.position.y
	)
	var bottom_right: Vector2 = Vector2(
		board_rect.position.x + board_rect.size.x, board_rect.position.y + board_rect.size.y
	)
	var bottom_left: Vector2 = Vector2(
		board_rect.position.x, board_rect.position.y + board_rect.size.y
	)
	
	var visited: PackedByteArray = []
	
	var rects: Array[Rect2] = []
	
	var width: int = (top_right.x - top_left.x)
	var height: int = (bottom_right.y - top_right.y)
	visited.resize(width*height)
	print("Board: ", str(board_rect))
	for r:int in width:
		for d:int in height:
			
			var rect: Rect2 = Rect2()
			var cell: int = d*width + r
			rect.position = Vector2(r, d) + top_left
			
			if visited[cell] != 0 or is_occupied(Vector2(r, d) + top_left):
				visited[cell] = 1
				continue
			rect.size = Vector2(1, 1)
			visited[cell] = 1
			
			# horizontal expansion
			for inner_r:int in range(1, width):
				
				if inner_r + r > width - 1:
					break
				
				if visited[inner_r + cell] != 0 or is_occupied(Vector2(r + inner_r, d) + top_left):
					break
				
				visited[inner_r + cell] = 1
				rect.size.x += 1
			
			# vertical expansion
			var failed_vertical: bool = false
			for inner_d:int in range(1, height):
				
				if inner_d + d > height - 1:
					break
				
				for i:int in rect.size.x:
					
					if visited[(d + inner_d)*width + (r+i)] != 0 or is_occupied(Vector2(r + i, d+inner_d) + top_left):
						failed_vertical = true
						break
				
				if failed_vertical:
					break
				
				for i:int in rect.size.x:
					visited[(d + inner_d)*width + (r+i)] = 1
				
				rect.size.y += 1
				
			
			rects.append(rect)
			
		
	#print(rects)
	print(rects.size())
	$RectDrawer.draw(rects)
	#LevelSaver.Save(level_data)

func ChangeGameRule(key: String, value: Variant) -> void:
	level_data[key] = value

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if DoesObjectOnMouseExist():
			RemoveObject(UTIL.cellurize_vector(get_global_mouse_position() + Vector2(32, 32)))

func DoesObjectOnMouseExist() -> bool:
	var cell: Vector2i = UTIL.cellurize_vector(get_global_mouse_position() + Vector2(32, 32))
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

func expand_board(at_cell: Vector2i) -> void:
	# forward expansion
	if at_cell.x > board_rect.position.x + board_rect.size.x:
		board_rect.size.x += (at_cell.x - (board_rect.size.x + board_rect.position.x)) + 1
	if at_cell.y > board_rect.position.y + board_rect.size.y:
		board_rect.size.y += (at_cell.y - (board_rect.size.y + board_rect.position.y)) + 1
	
	
	# bacward expansion
	if at_cell.x < board_rect.position.x:
		var size_change: int = (at_cell.x - board_rect.position.x)
		board_rect.position.x += (at_cell.x - board_rect.position.x)
		board_rect.size.x += abs(size_change)
	if at_cell.y < board_rect.position.y:
		var size_change: int = (at_cell.y - board_rect.position.y)
		board_rect.position.y += size_change
		board_rect.size.y += abs(size_change)
		
	

var board_rect_initiated: bool = false
func PlaceObject(object_name: String, at_cell: Vector2i) -> void:
	assert(
		not objects_data.has(at_cell),
		"There is already an object at cell")
	var id: int = 0
	
	if not board_rect_initiated:
		board_rect = Rect2(at_cell, Vector2(0, 0))
		board_rect_initiated = true
	expand_board(at_cell)
	objects_data[at_cell] = object_name
	
	match object_name:
		"soldier":
			id = 0
		"ascension":
			id = 1
		_:
			assert(false, "No object with name: " + str(object_name))
	
	OBJECTS.set_cell(at_cell, 0, Vector2i(id, 0))
