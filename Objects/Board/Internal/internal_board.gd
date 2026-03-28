class_name InternalBoard
extends RefCounted

var board: Board
var background: Node2D
var a: Vector2i = Vector2i.ZERO

func _init(board: Board) -> void:
	self.board = board

#region MUST OVERRIDE
## check if soldier exists based on specific internal system
func DoesSoldierExist(at_cell: Vector2i) -> bool:
	return false

## get soldier based on specific internal system
func RetrieveSoldier(_at_cell: Vector2i) -> Soldier:
	return null

## remove/hide soldier based on internal system
func EraseSoldier(_at_cell: Vector2i) -> void:
	pass

## show/place soldier based on internal system
func ReviveSoldier(_at_cell: Vector2i) -> void:
	pass

## often called from camera shifts
func BoardShift(_new_cell: Vector2i) -> void:
	pass
#endregion

## literal creation of a soldier object
const SOLDIER: PackedScene = preload("res://Objects/Soldiers/soldier.tscn")
func CreateSoldier(at_cell: Vector2i) -> Soldier:
	var soldier: Soldier = SOLDIER.instantiate()
	board.add_child(soldier)
	soldier.position = at_cell*64
	return soldier
