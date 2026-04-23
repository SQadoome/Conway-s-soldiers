class_name UTIL
extends Object


enum DIRECTIONS {
	LEFT, RIGHT, UP, DOWN,
	UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT,
}

static func cellurize_vector(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x/64.0), floori(position.y/64.0))

static func vectorize_cell(cell: Vector2i) -> Vector2:
	return Vector2(cell.x, cell.y)*64

const TILES: Texture = preload("res://Assets/Sprites/levels_grid.png")
static func create_bg_tile(at_cell: Vector2i) -> Sprite2D:
	var bg_tile: Sprite2D = Sprite2D.new()
	bg_tile.texture = TILES
	bg_tile.hframes = 9
	bg_tile.frame = 8
	bg_tile.scale = Vector2(0.5, 0.5)
	bg_tile.position = at_cell*64
	bg_tile.z_index = -1
	return bg_tile
	
