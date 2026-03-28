class_name Reactive
extends Resource

signal react(new_value: Variant)

var connections: Array[Reactive] = []

func AddConnection(connection: Reactive) -> void:
	connections.append(connection)
	connection.react.connect(OnConnectionReact)

func OnConnectionReact(connection: Reactive) -> void:
	pass
