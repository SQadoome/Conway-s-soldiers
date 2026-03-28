class_name GUIObjectMenu
extends Control

signal object_selected(object_name: String)
var objects: Array[MenuObject] = []

func _ready() -> void:
	GameEvents.gui_eventer.object_menu_fold_request.connect(Fold)
	GameEvents.gui_eventer.object_menu_unfold_request.connect(UnFold)
	
	for obj:MenuObject in get_node("HBoxContainer").get_children():
		obj.selected.connect(func(object:MenuObject):
			GameEvents.gui_eventer.emit_signal(
				"object_menu_object_selected", obj.object_name))
		objects.append(obj)
	GameEvents.gui_eventer.emit_signal("object_menu_object_selected", objects[0].object_name)

func Fold() -> void:
	GameEvents.gui_eventer.emit_signal(
		"object_menu_fold_transition_started"
	)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 132.0), 0.5)
	tween.finished.connect(func():
		tween.kill()
		GameEvents.gui_eventer.emit_signal(
			"object_menu_fold_transition_finished"
		))

func UnFold() -> void:
	GameEvents.gui_eventer.emit_signal(
		"object_menu_fold_transition_started"
	)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -132.0), 0.5)
	tween.finished.connect(func():
		tween.kill()
		GameEvents.gui_eventer.emit_signal(
			"object_menu_fold_transition_finished"
		))
