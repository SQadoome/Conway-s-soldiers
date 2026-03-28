class_name ItemSelection
extends ItemList

signal selected_item(item: String)

func _ready() -> void:
	item_selected.connect(func(idx: int):
		emit_signal("selected_item", get_item_text(idx)))
	
