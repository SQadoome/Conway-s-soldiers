class_name Line
extends Line2D

signal dull

## the signal that indicates the line needs to change
func _init(shift_signal: Signal = dull) -> void:
	if shift_signal != dull:
		shift_signal.connect(UpdateLine)

func UpdateLine(board_cell: Vector2i) -> void:
	set_point_position(0, Vector2(board_cell.x*64 + -2000, -32))
	set_point_position(1, Vector2(board_cell.x*64 + 2000, -32))

func _ready() -> void:
	z_index = -1
	add_point(Vector2(-2000, -32))
	add_point(Vector2(2000, -32))
	width = 16
	default_color = Color.CRIMSON
	GameEvents.creator_board_eventer.game_rule_changed.connect(
		func(key: String, value):
			if key == "line":
				visible = value
	)
