class_name InfiniteInternal
extends InternalBoard

# below line
var dead_locations: Dictionary[Vector2i, int] = {} 
# above line
var alive_locations: Dictionary[Vector2i, int] = {}

var locations: PackedVector2Array = []

var soldiers: Array[Soldier] = []

var size: int = 35
var anchor: Vector2i = Vector2i.ZERO


#region set-ups
func _init(board: Node2D) -> void:
	super(board)
	SetUp()

func SetUp() -> void:
	locations.resize(size*size)
	soldiers.resize(size*size)
	
	for x in size:
		for y in size:
			locations[x*size + y] = Vector2(x, y)
			soldiers[x*size + y] = CreateSoldier(Vector2(x, y))

#endregion

#region parent overriding
func BoardShift(new_cell: Vector2i) -> void:
	super(new_cell)
	UpdateSoldiers(new_cell - anchor)
	anchor = new_cell

func DoesSoldierExist(at_cell: Vector2i) -> bool:
	if at_cell.y < 0:
		return alive_locations.has(at_cell)
	return RetrieveSoldier(at_cell).visible

func ReviveSoldier(at_cell: Vector2i) -> void:
	var box_cell: Vector2i = at_cell - anchor
	soldiers[box_to_internal(box_cell)].visible = true
	
	# update shader
	if at_cell.y < 0:
		alive_locations[at_cell] = 0
		soldiers[box_to_internal(box_cell)].SetShaderInfluence(at_cell.y/100.0)
	else:
		dead_locations.erase(at_cell)
		soldiers[box_to_internal(box_cell)].SetShaderInfluence(0.0)

## get soldier in world tile
## (tile is automatically converted to internal state)
func RetrieveSoldier(global_cell: Vector2i) -> Soldier:
	return soldiers[box_to_internal(global_to_box(global_cell))]

## HIDES a soldier by converting its world-coords into internal sate
func EraseSoldier(at_cell: Vector2i) -> void:
	soldiers[box_to_internal(global_to_box(at_cell))].visible = false
	dead_locations[at_cell] = 0
	alive_locations.erase(at_cell)

#endregion

#region fuck this method
var next: Vector2i = Vector2i.ZERO
var un_next: Vector2i = Vector2i(size -1 , size - 1)
var state: Vector2i = Vector2i.ZERO
func UpdateSoldiers(shift_dir: Vector2i) -> void:
	var new_dir: Vector2i = Vector2i(sign(shift_dir.x), sign(shift_dir.y))
	var pointer: Vector2i = Vector2i.ZERO # pointer to current row/column
	var x_count = 0
	for x in get_range(shift_dir.x):
		# save changes
		state.x = pointer_to_box(state.x, new_dir.x)
		
		# setup next move
		if new_dir.x == -1: pointer.x = un_next.x 
		else: pointer.x = next.x
		
		# move soliders
		for y in size:
			x_count += 1
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
			soldiers[(x)*size + pointer.y].position.y += (64*size)*new_dir.y
			
			# check if above line
			# note to self, soldiers must be MOVED before checking
			if vec_to_cell(soldiers[(x)*size + pointer.y].position).y < 0:
				soldiers[(x)*size + pointer.y].SetShaderInfluence(vec_to_cell(soldiers[(x)*size + pointer.y].position).y/100.0)
				if alive_locations.has(vec_to_cell(soldiers[(x)*size + pointer.y].position)):
					soldiers[(x)*size + pointer.y].show()
				else:
					soldiers[(x)*size + pointer.y].hide()
				continue
			else:
				soldiers[(x)*size + pointer.y].SetShaderInfluence(0)
			
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
#endregion


#region coordinates-system
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
func IsOutOfBounds(global_cell: Vector2i) -> bool:
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
#endregion
