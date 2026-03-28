class_name PropertiesHolder
extends Control

var props: Array[BObjectProperty] = []

func _ready() -> void:
	hide()

func ConnectRequests(show_request: Signal, hide_request) -> void:
	pass

func OnRequestShowProperties(props: Array[BObjectProperty]) -> void:
	pass

func OnRequestHideProperties() -> void:
	for i in get_children():
		i.queue_free()

func AddProperty(prop: BObjectProperty) -> void:
	props.append(prop)
	var property_gui: Property = load("res://Objects/GUI/property.tscn").instantiate()
	property_gui.ConnectProperty(prop.property_changed, prop.title)
	get_node("VBoxContainer").add_child(property_gui)
