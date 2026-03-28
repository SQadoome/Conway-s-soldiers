class_name CreatorBoardEventer
extends Resource

signal object_selected(obj: BoardObject)
signal object_deleted(obj: BoardObject)
signal object_painted(obj: BoardObject)
signal object_removed(obj: BoardObject)
signal multiple_object_paint(objects: Array[BoardObject])
signal game_rule_changed(key: String, value: Variant)
signal save
