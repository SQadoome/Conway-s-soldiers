class_name ActivationDetector
extends Node2D

var enabled: bool = true
var tile: Vector2i = Vector2i.ZERO

signal activated(move: Move)

func _enter_tree() -> void:
	pass

func set_tile(_tile: Vector2i) -> void:
	global_position = UTIL.vectorize_cell(_tile)
	tile = _tile
	GameEvents.ingame_board_eventer.update_activation_detector.emit(self)
	

func activate(move: Move) -> void:
	activated.emit(move)
	
