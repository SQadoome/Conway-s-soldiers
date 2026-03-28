class_name Soldier
extends Node2D

static var shader: Shader = preload("res://Objects/Soldiers/soldier.gdshader")
var moves: Array[Move] = []

func _ready() -> void:
	SetShaderInfluence(0.0)

func SetMoves(moves: Array[Move]) -> void:
	self.moves = moves

func SetShaderInfluence(new_value: float) -> void:
	get_node("Sprite2D").material.set_shader_parameter("influence", new_value)
