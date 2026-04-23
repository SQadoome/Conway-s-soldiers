class_name InfiniteInternal
extends Node2D

static var thread: Thread = Thread.new()

# below line
var dead_locations: Dictionary[Vector2i, int] = {} 
# above line
var alive_locations: Dictionary[Vector2i, int] = {}

var locations: PackedVector2Array = []
var soldiers: Array[Soldier] = []

var size: int = 64
var anchor: Vector2i = Vector2i.ZERO

@export var camera: SmartCamera

func _enter_tree() -> void:
	_instantiate();
	
	camera.camera_shifted.connect(_on_camera_shift);
	camera.offset = Vector2(size/2, size/2)*64;
	camera.simulate_shift(Vector2(-size/2, -size/2));
	

const SOLDIER: PackedScene = preload("res://Objects/Soldiers/soldier.tscn")
func create_soldier() -> Sprite2D:
	var soldier: Soldier = SOLDIER.instantiate()
	add_child(soldier)
	return soldier

func _instantiate() -> void:
	locations.resize(size*size);
	soldiers.resize(size*size);
	
	for x:int in size:
		for y:int in size:
			var location: Vector2 = Vector2(x, y);
			var soldier: Soldier = create_soldier();
			
			locations[x*size + y] = location;
			soldiers[x*size + y] = soldier;
			soldier.position = location*64;
			
		
	

func _on_camera_shift(old_cell: Vector2i, new_cell: Vector2i) -> void:
	update_soldiers(new_cell - anchor);
	anchor = new_cell;

func does_soldier_exist(at_cell: Vector2i) -> bool:
	if at_cell.y < 0:
		return alive_locations.has(at_cell);
	return retrieve_soldier(at_cell).visible;

func revive_soldier(at_cell: Vector2i) -> void:
	var box_cell: Vector2i = at_cell - anchor;
	soldiers[box_to_internal(box_cell)].visible = true;
	
	# update shader
	if at_cell.y < 0:
		alive_locations[at_cell] = 0;
		soldiers[box_to_internal(box_cell)].set_shader_influence(at_cell.y/100.0);
	else:
		dead_locations.erase(at_cell);
		soldiers[box_to_internal(box_cell)].set_shader_influence(0.0);

## get soldier in world tile
## (tile is automatically converted to internal state)
func retrieve_soldier(global_cell: Vector2i) -> Sprite2D:
	return soldiers[box_to_internal(global_to_box(global_cell))];

## HIDES a soldier by converting its world-coords into internal sate
func erase_soldier(at_cell: Vector2i) -> void:
	soldiers[box_to_internal(global_to_box(at_cell))].visible = false;
	dead_locations[at_cell] = 0;
	alive_locations.erase(at_cell);

var next: Vector2i = Vector2i.ZERO
var un_next: Vector2i = Vector2i(size -1 , size - 1)
var state: Vector2i = Vector2i.ZERO
func update_soldiers(shift_dir: Vector2i) -> void:
	var new_dir: Vector2i = Vector2i(sign(shift_dir.x), sign(shift_dir.y))
	var pointer: Vector2i = Vector2i.ZERO # pointer to current row/column
	var iteration_count: int = 0
	var start_time: int = Time.get_ticks_usec()
	
	for x in get_range(shift_dir.x):
		# save changes
		state.x = pointer_to_box(state.x, new_dir.x)
		
		# setup next move
		if new_dir.x == -1: pointer.x = un_next.x 
		else: pointer.x = next.x
		
		# move soliders
		for y in size:
			iteration_count += 1
			soldiers[(pointer.x)*size + y].position.x += (64*size)*new_dir.x
			
			# check if above line
			# note to self, soldiers must be MOVED before checking
			if vec_to_cell(soldiers[(pointer.x)*size + y].position).y < 0:
				if alive_locations.has(vec_to_cell(soldiers[(pointer.x)*size + y].position)):
					soldiers[(pointer.x)*size + y].show()
				else: 
					soldiers[(pointer.x)*size + y].hide()
				continue
			
			if dead_locations.has(vec_to_cell(soldiers[(pointer.x)*size + y].position)):
				soldiers[(pointer.x)*size + y].hide()
			else: soldiers[(pointer.x)*size + y].show()
		
		# update moves
		if new_dir.x == -1:
			un_next.x = pointer_to_box(un_next.x, -1)
			next.x = pointer_to_box(next.x, -1)
		else:
			next.x = pointer_to_box(next.x, 1)
			un_next.x = pointer_to_box(un_next.x, 1)
	
	for y in get_range(shift_dir.y):
		# save changes
		state.y = pointer_to_box(state.y, new_dir.y)
		
		# setup next move
		if new_dir.y == -1: pointer.y = un_next.y 
		else: pointer.y = next.y
		
		# move soldiers
		for x in size:
			iteration_count += 1
			soldiers[(x)*size + pointer.y].position.y += (64*size)*new_dir.y
			
			# check if above line
			# note to self, soldiers must be MOVED before checking
			if vec_to_cell(soldiers[(x)*size + pointer.y].position).y < 0:
				soldiers[(x)*size + pointer.y].set_shader_influence(vec_to_cell(soldiers[(x)*size + pointer.y].position).y/100.0)
				if alive_locations.has(vec_to_cell(soldiers[(x)*size + pointer.y].position)):
					soldiers[(x)*size + pointer.y].show()
				else:
					soldiers[(x)*size + pointer.y].hide()
				continue
			else:
				soldiers[(x)*size + pointer.y].set_shader_influence(0)
			
			if dead_locations.has(vec_to_cell(soldiers[(x)*size + pointer.y].position)):
				soldiers[(x)*size + pointer.y].hide()
			else: soldiers[(x)*size + pointer.y].show()
		
		# update moves
		if new_dir.y == -1:
			un_next.y = pointer_to_box(un_next.y, -1)
			next.y = pointer_to_box(next.y, -1)
		else:
			next.y = pointer_to_box(next.y, 1)
			un_next.y = pointer_to_box(un_next.y, 1)
		
	var end_time: int = Time.get_ticks_usec()
	print("Iterations: ", iteration_count, " | Estimated loop time: ", (end_time - start_time) / 1000000.0, " | FPS: ", Engine.get_frames_per_second())
	


## from box to internal array state
func box_to_internal(box_cell: Vector2i) -> int:
	return ((box_cell.x + state.x) % size)*size + (box_cell.y + state.y) % size

## from world coords to box coords
func global_to_box(global_cell: Vector2i) -> Vector2i:
	return global_cell - anchor

## 64 cell-size
func vec_to_cell(at_pos: Vector2) -> Vector2i:
	return Vector2i(floori(at_pos.x/64.0), floori(at_pos.y/64.0))

## fixes negatives by going in descending-order (positive-values-only)
static func get_range(target: int) -> PackedInt32Array:
	var result: PackedInt32Array = []
	if target > 0:
		result = range(0, target)
		return result
	if target < 0:
		result = range(target, 0)
		return result
	
	return result

## check if a world coords is out of specified bounds/box
func is_out_of_bounds(global_cell: Vector2i) -> bool:
	var box_cell: Vector2i = global_to_box(global_cell)
	if !(box_cell.x >= 0 && box_cell.x < size) or !(box_cell.y >= 0 && box_cell.y < size) or dead_locations.has(global_cell):
		return true
	else:
		return false

func pointer_to_box(pointer_state: int, direction: int) -> int:
	if direction == -1:
		
		if pointer_state - 1 < 0:
			return size - 1
		return pointer_state - 1
	else:
		return (pointer_state + 1) % size
	
	return 0


#@export var camera: SmartCamera
#
#var soldiers: Array[RID] = []
#var soldier_positions: PackedVector2Array = []
#
#var dead_soldiers: Dictionary[Vector2i, bool] = {}
#
## above line
#var line_alive_soldiers: Dictionary[Vector2i, bool] = {}
#
#var anchor: Vector2i = Vector2i.ZERO
#
#var row_ptr: int = 0
#var col_ptr: int = 0
#
#var x_length: int = 10
#var y_length: int = 10
#
#func _enter_tree() -> void:
	#camera.camera_shifted.connect(_on_camera_shift)
	#camera.camera_scaled.connect(_on_camera_scale)
	#
	#_instantiate()
	#
#
#func _instantiate() -> void:
	#soldiers.resize(x_length*y_length)
	#soldier_positions.resize(y_length*x_length)
	#
	#for x:int in x_length:
		#for y:int in y_length:
			#
			#var soldier: RID = create_soldier()
			#soldiers[y*y_length + x] = soldier
			#soldier_positions[y*y_length + x] = Vector2(x, y)
			#
			#RenderingServer.canvas_item_set_transform(
				#soldier,
				#Transform2D().translated(Vector2(x, y)*128).scaled(Vector2(0.5, 0.5))
				#)
			#
		#
	#
#
#func world_2_box(world_cell: Vector2i) -> Vector2i:
	#return world_cell - anchor
#
#func box_2_internal(box_cell: Vector2i) -> int:
	#return ((box_cell.x + row_ptr) % x_length)*x_length + (box_cell.y + col_ptr) % y_length
 #
#func DoesSoldierExist(at_cell: Vector2i) -> bool:
	#return false
#
#func revive_soldier(at_cell: Vector2i) -> void:
	#if at_cell.y >= 0:
		#line_alive_soldiers[at_cell] = true
	#else:
		#assert(dead_soldiers.has(at_cell))
		#dead_soldiers.erase(at_cell)
	#
#
#func remove_soldier(at_cell: Vector2i) -> void:
	#if at_cell.y < 0:
		#assert(line_alive_soldiers.has(at_cell))
		#line_alive_soldiers.erase(at_cell)
	#else:
		#dead_soldiers[at_cell] = true
	#
#
#func is_soldier_alive(at_cell: Vector2) -> bool:
	#return false
#
#func is_cell_occupied(at_cell: Vector2) -> bool:
	#return false
#
#func _on_camera_shift(old_cell: Vector2i, new_cell: Vector2i) -> void:
	#var shift_value: Vector2i = new_cell - old_cell
	#anchor += shift_value
	#
	#update_soldiers(shift_value)
	#
#
#func update_soldiers(c_shift: Vector2i) -> void:
	#var x_dir: int = sign(c_shift.x)
	#
	## columns
	#for shift:int in c_shift.x:
		#
		#
		#for row:int in x_length:
			#
			## cell: [col_ptr*y_length + x]
			#var next: int = ((row + col_ptr) % y_length)
			#soldier_positions[next*y_length].x += x_length
			#move_soldier(soldiers[next*y_length], soldier_positions[next*y_length]*64)
			#
		#col_ptr = (col_ptr + 1) % x_length
		#
	#
#
#func _on_camera_scale(old_zoom: Vector2i, new_zoom: Vector2) -> void:
	#pass
#
#const soldier_sprite: Texture = preload("res://Assets/Sprites/Soldier.png")
#
#func move_soldier(soldier: RID, to_pos: Vector2i) -> void:
	#RenderingServer.canvas_item_set_transform(soldier, Transform2D().translated(to_pos).scaled(Vector2(0.5, 0.5)))
	#
#
#func create_soldier() -> RID:
	#var soldier_rid: RID = RenderingServer.canvas_item_create()
	#
	#RenderingServer.canvas_item_set_parent(
		#soldier_rid, get_canvas_item()
	#)
	#RenderingServer.canvas_item_add_texture_rect(
		#soldier_rid,
		#Rect2(-soldier_sprite.get_size()/2, soldier_sprite.get_size()),
		#soldier_sprite
	#)
	#
	#RenderingServer.canvas_item_set_transform(
		#soldier_rid, Transform2D().translated(Vector2(0, -64)).scaled(Vector2(0.5, 0.5))
	#)
	#RenderingServer.canvas_item_reset_physics_interpolation(soldier_rid)
	#return soldier_rid
#
#func destroy_soldier(rid: RID) -> void:
	#RenderingServer.free_rid(rid)
