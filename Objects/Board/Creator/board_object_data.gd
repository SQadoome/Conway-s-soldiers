class_name BoardObjectData
extends Resource

var visible_sprite: Texture
var properties: Array[BObjectProperty] = []

func AddProperty(property: BObjectProperty) -> void:
	properties.append(property)

func GetProperties() -> Array[BObjectProperty]:
	return properties
