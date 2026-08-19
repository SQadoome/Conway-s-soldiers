class_name FiniteInternal
extends Node2D

#var soldiers: Dictionary[Vector2i, Soldier] = {}
#
#func _init(board: Board, data: LevelData) -> void:
	#board.CAMERA.offset = Vector2(0, 0)
	#for loc:Vector2i in data.soldier_locations:
		#var soldier: Soldier = CreateSoldier(loc)
		#soldier.z_index = 1
		#soldiers[loc] = soldier
#
### check if soldier exists based on specific internal system
#func DoesSoldierExist(at_cell: Vector2i) -> bool:
	#return soldiers.has(at_cell)
#
### get soldier based on specific internal system
#func RetrieveSoldier(at_cell: Vector2i) -> Soldier:
	#return soldiers[at_cell]
#
### remove/hide soldier based on internal system
#func EraseSoldier(at_cell: Vector2i) -> void:
	#if soldiers.has(at_cell):
		#soldiers[at_cell].queue_free()
	#soldiers.erase(at_cell)
#
### show/place soldier based on internal system
#func ReviveSoldier(at_cell: Vector2i) -> void:
	#soldiers[at_cell] = CreateSoldier(at_cell)
#
### often called from camera shifts
#func BoardShift(new_cell: Vector2i) -> void:
	#super(new_cell)
