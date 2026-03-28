class_name PaintObjectFactory
extends Resource

const SOLDIER_SPRITE: Texture = preload("res://Assets/Sprites/Soldier.png")
const ASCEND_SPRITE: Texture = preload("res://Assets/Sprites/ascend_tile.png")

static var operations: Dictionary[String, Callable] = {
	"soldier": func() -> SoldierObject:
		var holder: SoldierObject = SoldierObject.new()
		GenerateSprite(holder, SOLDIER_SPRITE).scale = Vector2(0.5, 0.5)
		return holder,
	"ascension": func() -> AscensionObject:
		var holder: AscensionObject = AscensionObject.new()
		GenerateSprite(holder, ASCEND_SPRITE)
		return holder,
}

static func GenerateSprite(holder: BoardObject, image: Texture) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = image
	holder.add_child(sprite)
	return sprite

static func GenerateObject(object_name: String) -> BoardObject:
	return operations[object_name].call()
