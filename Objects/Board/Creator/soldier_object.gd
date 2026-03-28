class_name SoldierObject
extends BoardObject


func _ready() -> void:
	super()
	properties_holder.AddProperty(
		PositionProperty.new(cell_changed)
	)
	emit_signal("cell_changed", UTIL.CellurizeVector(position))
