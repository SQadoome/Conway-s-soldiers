class_name TileUtil
extends Object

enum DIRECTIONS {
	LEFT, RIGHT, UP, DOWN,
	UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT,
}

const tile_size: float = 128.0

static func cellurize_vector(position: Vector2) -> Vector2:
	return Vector2i(floori(position.x/tile_size), floori(position.y/tile_size))

static func vectorize_cell(cell: Vector2) -> Vector2:
	return cell*tile_size + Vector2(0.5, 0.5)*tile_size

static func vectorize_centered_cell(cell: Vector2) -> Vector2:
	return cell*tile_size

static func generate_orthogonal_directions() -> PackedVector2Array:
	var directions: PackedVector2Array = [];
	directions.append(Vector2i.RIGHT);
	directions.append(Vector2i.LEFT);
	directions.append(Vector2i.UP);
	directions.append(Vector2i.DOWN);
	return directions;
	

static func generate_diagonal_directions() -> PackedVector2Array:
	var directions: PackedVector2Array = [];
	directions.append(Vector2i(-1, -1));
	directions.append(Vector2i(1, -1));
	directions.append(Vector2i(-1, 1));
	directions.append(Vector2i(1, 1));
	return directions;

static func generate_square_directions() -> PackedVector2Array:
	var directions: PackedVector2Array = [];
	directions.append(Vector2i.RIGHT);
	directions.append(Vector2i.LEFT);
	directions.append(Vector2i.UP);
	directions.append(Vector2i.DOWN);
	directions.append(Vector2i(-1, -1));
	directions.append(Vector2i(1, -1));
	directions.append(Vector2i(-1, 1));
	directions.append(Vector2i(1, 1));
	return directions;
	

static func generate_line_cells(direction: Vector2, length: int, start_cell: Vector2) -> PackedVector2Array:
	var cells := PackedVector2Array();
	cells.resize(length);
	
	for i:int in length:
		cells[i] = direction*i;
	
	return cells;
