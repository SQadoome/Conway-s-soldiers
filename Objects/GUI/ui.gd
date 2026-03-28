extends Control


func _on_button_2_pressed() -> void:
	GameEvents.ingame_board_eventer.emit_signal("reset")


func _on_button_pressed() -> void:
	GameEvents.ingame_board_eventer.emit_signal("leave")
