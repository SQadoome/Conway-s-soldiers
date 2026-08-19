class_name BoardObject
extends Node

var cell: Vector2 = Vector2.ZERO
var occupies_tile: bool = false

var components: Dictionary[BObjectComponent.Components, Resource] = {}

func has_component(comp_type: BObjectComponent.Components) -> bool:
	return components.has(comp_type);
	

func get_component(comp_type: BObjectComponent.Components) -> BObjectComponent:
	if (components.has(comp_type) == false):
		assert(false);
		return null;
	return components[comp_type];
	

func add_component(comp: BObjectComponent) -> void:
	assert(not components.has(comp.type));
	components[comp.type] = comp;
	comp.board_object = self;
	
