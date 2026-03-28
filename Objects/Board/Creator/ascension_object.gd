class_name AscensionObject
extends BoardObject

func _ready() -> void:
	super()
	properties_holder.AddProperty(
		PositionProperty.new(cell_changed)
	)
	properties_holder.AddProperty(
		SizeProperty.new(size_changed)
	)
	emit_signal("size_changed", Vector2(1, 1))
	emit_signal("cell_changed", UTIL.CellurizeVector(position))
