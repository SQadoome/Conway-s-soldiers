class_name CreatorGUI
extends Control

# refcounted, need a refrence
var board_type: Impulsive
var line_toggle: Impulsive
var save_request: Impulsive

func _ready() -> void:
	board_type = Impulsive.new().connect_impulse($ItemList.selected_item)
	board_type.impulsed.connect(func(value: String):
		GameEvents.creator_board_eventer.emit_signal(
			"game_rule_changed", "board", value
		))
	line_toggle = Impulsive.new().connect_impulse($Line/CheckBox.toggled)
	line_toggle.impulsed.connect(func(value: bool):
		GameEvents.creator_board_eventer.emit_signal(
			"game_rule_changed", "line", value
		))
	save_request = Impulsive.new().connect_impulse($SaveButton.pressed)
	save_request.impulsed.connect(func(v: String): GameEvents.creator_board_eventer.emit_signal("save"))
	
	
	get_node("Menu/Button").pressed.connect(func():
		$Menu/Insides.visible = true)
	get_node("Menu/Insides/Buttons/ExitMenu").pressed.connect(func():
		$Menu/Insides.visible = false)
	
