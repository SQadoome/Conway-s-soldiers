
extends Node2D
var board: Dictionary[Vector2i, BoardObject] = {}

var soldiers: Dictionary[Vector2i, RID] = {}
var hidden_soldiers: Dictionary[Vector2i, bool] = {}

var sd_canvas: RID
var sd_canvas_setted: bool = false

func _enter_tree() -> void:
	pass
	

func set_soldier_canvas(canvas: RID) -> void:
	sd_canvas = canvas;
	sd_canvas_setted = true;
	

func add_object(object: BoardObject, at_cell: Vector2i) -> void:
	assert(not (object == null));
	assert(not board.has(at_cell));
	
	board[at_cell] = object;

func remove_object(at_cell: Vector2i) -> void:
	assert(board.has(at_cell));
	board.erase(at_cell);

func is_cell_occupied(at_cell: Vector2i) -> bool:
	if (board.has(at_cell)):
		return board[at_cell].occupies_tile;
	
	if (soldiers.has(at_cell)):
		return true;
	
	return false;
	

func retrieve_object(at_cell: Vector2i) -> BoardObject:
	assert(board.has(at_cell) or soldiers.has(at_cell));
	if (board.has(at_cell)):
		return board[at_cell];
	
	return null;

func does_soldier_exist(at_cell: Vector2i) -> bool:
	return soldiers.has(at_cell) or hidden_soldiers.has(at_cell);
	

func create_soldier(at_cell: Vector2i) -> void:
	assert(not soldiers.has(at_cell));
	print(at_cell)
	
	var pos: Vector2 = TileUtil.vectorize_cell(at_cell);
	var ci_rid: RID = RenderingServer.canvas_item_create();
	if (sd_canvas_setted == false):
		RenderingServer.canvas_item_set_parent(ci_rid, get_canvas_item());
	else:
		RenderingServer.canvas_item_set_parent(ci_rid, sd_canvas);
	
	var sd_texture: Texture2D = GlobalAssets.SOLDIER_TEXTURE;
	RenderingServer.canvas_item_add_texture_rect(
		ci_rid,
		Rect2(-sd_texture.get_size() / 2, sd_texture.get_size()),
		GlobalAssets.SOLDIER_TEXTURE);
	
	RenderingServer.canvas_item_set_transform(
		ci_rid, Transform2D().translated(pos));
	
	soldiers[at_cell] = ci_rid;
	

func create_hidden_soldier(at_cell: Vector2i) -> void:
	hidden_soldiers[at_cell] = true;
	

func create_soldiers(cells: PackedVector2Array) -> void:
	for i:Vector2i in cells:
		create_soldier(i);
	

func destroy_soldier(at_cell: Vector2i) -> void:
	assert(soldiers.has(at_cell) or hidden_soldiers.has(at_cell));
	
	if (soldiers.has(at_cell)):
		var sd_rid: RID = soldiers[at_cell];
		soldiers.erase(at_cell);
		RenderingServer.canvas_item_reset_physics_interpolation(sd_rid);
		RenderingServer.free_rid(sd_rid);
		return
	
	if (hidden_soldiers.has(at_cell)):
		hidden_soldiers.erase(at_cell);
		return
	

func destroy_soldiers(cells: PackedVector2Array) -> void:
	for i:Vector2i in cells:
		destroy_soldier(i);
	
