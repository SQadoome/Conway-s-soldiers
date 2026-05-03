class_name IngameBoard
extends Node2D

var ghosts: Array[GhostSoldier] = []
var movers: Array[MovingSoldier] = []
var activation_detectors: Dictionary[Vector2i, ActivationDetector] = {}

var level_data: LevelData

@export var internal_board: InfiniteInternal
@export var line: Line
@export var camera: SmartCamera
@export var input_listener: BoardInput

static var total_ascensions: int = 0
static var ascension_count: int = 0

const ASCENSION_TILE: PackedScene = preload("res://Objects/Board/Objects/ascend_tile.tscn")
const GHOST_SOLDIER: PackedScene = preload("res://Objects/Soldiers/ghost_soldier.tscn")
const BROKEN_SOLDIER: PackedScene = preload("res://Objects/Soldiers/broken_soldier.tscn")
const ANIMATED_SOLDIER: PackedScene = preload("res://Objects/Soldiers/moving_soldier.tscn")

var background: Node2D

func _enter_tree() -> void:
	total_ascensions = 0;
	ascension_count = 0;
	
	input_listener.cell_clicked_left.connect(ValidateCellRequest);
	input_listener.undo_request.connect(UndoLastMove);
	
	camera.camera_shifted.connect(shift_background);
	camera.camera_shifted.connect(
		func(old_cell: Vector2i, new_cell: Vector2i):
			$Limit.position.x = (new_cell - old_cell).x*64 + 1920/2;
	);
	
	for loc:Vector2i in level_data.ascensions:
		PutAscend(loc);
	
	GameEvents.ingame_board_eventer.set_board(internal_board);
	
	GameEvents.ingame_board_eventer.reset.connect(func(): camera.SimulateShift(Vector2i(0, -35/2)));
	GameEvents.ingame_board_eventer.ascension.connect(OnAscension);
	
	GameEvents.ingame_board_eventer.request_place_soldier.connect(internal_board.revive_soldier);
	GameEvents.ingame_board_eventer.request_remove_soldier.connect(internal_board.erase_soldier);
	GameEvents.ingame_board_eventer.request_soldier_move.connect(
		func(from: Vector2, to: Vector2) -> void:
			PlayMove(Move.new(from, to, [], {}));
	);
	
	GameEvents.ingame_board_eventer.update_activation_detector.connect(update_activation_detector)
	
	background = Node2D.new();
	for x in range(0, 35):
		for y in range(-16, 16):
			background.add_child(UTIL.create_bg_tile(Vector2(-x, y)));
			background.add_child(UTIL.create_bg_tile(Vector2(x, y)));
	background.z_index = -1
	add_child(background);
	

func shift_background(old_cell: Vector2i, new_cell: Vector2i) -> void:
	background.position = Vector2(new_cell*64) + Vector2(1920, 1080*2);
	

func _process(delta: float) -> void:
	var cell: Vector2i = UTIL.cellurize_vector(get_global_mouse_position() + Vector2(32, 32))
	$Highlight.position = cell*64
	if internal_board.does_soldier_exist(cell):
		$Highlight.show()
	else:
		$Highlight.hide()

var moves: Array[Move] = []
var move_count: int = 0
var move_pointer: int = 0
func AddMove(move: Move) -> void:
	moves.append(move)
	move_count += 1

func UndoLastMove() -> void:
	if move_count <= 0:
		return
	move_count -= 1
	
	var move: Move = moves[move_count]
	
	internal_board.erase_soldier(move.target_location)
	internal_board.revive_soldier(move.origin)
	for victim:Vector2i in move.victims:
		internal_board.revive_soldier(victim)
	ValidateCellRequest(move.origin)
	
	GameEvents.ingame_board_eventer.emit_signal(
		"undo_soldier_move",
		IngameBoardEventer.UndoSoldierMove.new(moves[move_count])
	)
	moves.remove_at(move_count)
	

func ValidateCellRequest(cell: Vector2i) -> void:
	for ghost:GhostSoldier in ghosts:
		ghost.queue_free()
	ghosts.clear()
	if internal_board.does_soldier_exist(cell):
		$Selection.position = cell*64
		$Selection.show()
		CreateGhosts(cell)
	else:
		$Selection.hide()
	

func PutAscend(at_cell: Vector2i) -> void:
	var tile: AscendTile = ASCENSION_TILE.instantiate()
	tile.position = at_cell*64
	total_ascensions += 1
	add_child(tile)

func OnAscension(a: IngameBoardEventer.Ascension) -> void:
	internal_board.erase_soldier(a.ascend_tile)
	if internal_board.does_soldier_exist(a.hook_tile):
		input_listener.DisableInput()
		internal_board.erase_soldier(a.hook_tile)
		AnimateSoldier(a.hook_tile, a.hook_tile + Vector2i.UP).finished.connect(
			func():
				internal_board.revive_soldier(a.hook_tile + Vector2i.UP)
				input_listener.EnableInput()
		)


func CreateGhost(move: Move) -> void:
	var ghost: GhostSoldier = GHOST_SOLDIER.instantiate()
	ghost.SetProperties(move)
	ghost.chosen.connect(PlayMove)
	ghosts.append(ghost)
	add_child(ghost)

func CreateGhosts(cell: Vector2i) -> void:
	var moves: Array[Move] = MoveGenerator.GenerateMoves(
		cell,
		level_data.move_set)
	moves = MoveReader.ReadMoves(moves, internal_board.does_soldier_exist)
	
	for move:Move in moves:
		CreateGhost(move)

func PlayAudio(stream: AudioStream) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = stream
	player.play()

const move_sfx: AudioStream = preload("res://Assets/Audio/MoveSound.mp3")
func PlayMove(data: Move) -> void:
	input_listener.DisableInput()
	PlayAudio(move_sfx)
	
	AddMove(data)
	
	internal_board.erase_soldier(data.origin)
	for victim:Vector2i in data.victims:
		BreakSoldier(victim)
		internal_board.erase_soldier(victim)
	
	var animated_soldier: MovingSoldier = AnimateSoldier(data.origin, data.target_location)
	animated_soldier.finished.connect(func():
		input_listener.EnableInput()
		movers.erase(animated_soldier)
		internal_board.revive_soldier(data.target_location)
		
		ValidateCellRequest(data.target_location)
		GameEvents.ingame_board_eventer.soldier_moved.emit(data) 
		
		if activation_detectors.has(data.target_location):
			activation_detectors[data.target_location].activate(data)
	)
	

func BreakSoldier(at_cell: Vector2i) -> void:
	var broken_soldier: BrokenSoldier = BROKEN_SOLDIER.instantiate()
	broken_soldier.position = at_cell*64
	add_child(broken_soldier)

func AnimateSoldier(from: Vector2i, to: Vector2i) -> MovingSoldier:
	var animated_soldier: MovingSoldier = ANIMATED_SOLDIER.instantiate()
	animated_soldier.set_properties(from*64, to*64)
	movers.append(animated_soldier)
	add_child(animated_soldier)
	return animated_soldier

func update_activation_detector(detector: ActivationDetector) -> void:
	activation_detectors.set(detector.tile, detector)
	
