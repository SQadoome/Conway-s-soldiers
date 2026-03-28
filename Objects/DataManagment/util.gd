class_name UTIL
extends Object

static func CellurizeVector(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x/64.0), floori(position.y/64.0))
