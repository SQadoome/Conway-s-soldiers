class_name IngameBoard
extends Board

var internal_board: InternalBoard
var ghosts: Array[GhostSoldier] = []
var movers: Array[MovingSoldier] = []

var level_data: LevelData

func ShiftBackground(new_cell: Vector2i) -> void:
	super(new_cell)
	# account for infinite internal non-negative positions
	# aka im to lazy to fix the "fuck this method" :)))
	background.position += Vector2(0, 35/2)*64

func _ready() -> void:
	total_ascensions = 0
	ascension_count = 0
	super()
	match level_data.board_type:
		"infinite":
			internal_board = InfiniteInternal.new(self)
		"finite":
			internal_board = FiniteInternal.new(self, level_data)
	for loc:Vector2i in level_data.ascensions:
		PutAscend(loc)
	
	GameEvents.ingame_board_eventer.reset.connect(func(): CAMERA.SimulateShift(Vector2i(0, -35/2)))
	GameEvents.ingame_board_eventer.ascension.connect(OnAscension)
	GameEvents.ingame_board_eventer.request_check_soldier.connect(
		func(tile: Vector2i): GameEvents.ingame_board_eventer.emit_signal(
			"request_check_soldier_accept",
			IngameBoardEventer.SoldierCheck.new(tile, internal_board.DoesSoldierExist(tile)))
	)
	GameEvents.ingame_board_eventer.request_place_soldier.connect(
		func(at_cell: Vector2i): internal_board.ReviveSoldier(at_cell)
	)
	GameEvents.ingame_board_eventer.request_remove_soldier.connect(
		func(at_cell: Vector2i): 
			internal_board.EraseSoldier(at_cell)
	)
	
	CAMERA.camera_shifted.connect(
		func(shift_thing: Vector2i):
			$Limit.position.x = shift_thing.x*64 + 1920/2
			internal_board.BoardShift(shift_thing))
	input_listener.cell_clicked_left.connect(ValidateCellRequest)
	input_listener.undo_request.connect(UndoLastMove)
	
	var line: Line = Line.new(CAMERA.camera_shifted)
	line.position += Vector2(35*64/2, 0)
	add_child(line)
	
	CAMERA.offset = Vector2(35*64/2, 35*64/2)
	CAMERA.SimulateShift(Vector2(0, -35/2))

func _process(delta: float) -> void:
	var cell: Vector2i = UTIL.CellurizeVector(get_global_mouse_position() + Vector2(32, 32))
	$Highlight.position = cell*64
	if internal_board.DoesSoldierExist(cell):
		$Highlight.show()
	else:
		$Highlight.hide()

#region move saving
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
	
	internal_board.EraseSoldier(move.target_location)
	internal_board.ReviveSoldier(move.origin)
	for victim:Vector2i in move.victims:
		internal_board.ReviveSoldier(victim)
	ValidateCellRequest(move.origin)
	
	GameEvents.ingame_board_eventer.emit_signal(
		"undo_soldier_move",
		IngameBoardEventer.UndoSoldierMove.new(moves[move_count])
	)
	moves.remove_at(move_count)
	

#endregion
func ValidateCellRequest(cell: Vector2i) -> void:
	for ghost:GhostSoldier in ghosts:
		ghost.queue_free()
	ghosts.clear()
	if internal_board.DoesSoldierExist(cell):
		$Selection.position = cell*64
		$Selection.show()
		CreateGhosts(cell)
	else:
		$Selection.hide()
	

static var total_ascensions: int = 0
static var ascension_count: int = 0

const ASCENSION_TILE: PackedScene = preload("res://Objects/Board/Objects/ascend_tile.tscn")
func PutAscend(at_cell: Vector2i) -> void:
	var tile: AscendTile = ASCENSION_TILE.instantiate()
	tile.position = at_cell*64
	total_ascensions += 1
	add_child(tile)

func OnAscension(a: IngameBoardEventer.Ascension) -> void:
	internal_board.EraseSoldier(a.ascend_tile)
	if internal_board.DoesSoldierExist(a.hook_tile):
		input_listener.DisableInput()
		internal_board.EraseSoldier(a.hook_tile)
		AnimateSoldier(a.hook_tile, a.hook_tile + Vector2i.UP).finished.connect(
			func():
				internal_board.ReviveSoldier(a.hook_tile + Vector2i.UP)
				input_listener.EnableInput()
		)

const GHOST_SOLDIER: PackedScene = preload("res://Objects/Soldiers/ghost_soldier.tscn")
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
	moves = MoveReader.ReadMoves(moves, internal_board.DoesSoldierExist)
	
	for move:Move in moves:
		CreateGhost(move)

func PlayAudio(stream: AudioStream) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.stream = stream
	player.play()

## play a soldier move
const move_sfx: AudioStream = preload("res://Assets/Audio/MoveSound.mp3")
func PlayMove(ghost_data: GhostData) -> void:
	input_listener.DisableInput()
	PlayAudio(move_sfx)
	AddMove(Move.new(ghost_data.origin, ghost_data.target, ghost_data.victims, {}))
	internal_board.EraseSoldier(ghost_data.origin)
	for victim:Vector2i in ghost_data.victims:
		BreakSoldier(victim)
		internal_board.EraseSoldier(victim)
	var animated_soldier: MovingSoldier = AnimateSoldier(ghost_data.origin, ghost_data.target)
	animated_soldier.finished.connect(func():
		input_listener.EnableInput()
		movers.erase(animated_soldier)
		internal_board.ReviveSoldier(ghost_data.target)
		
		ValidateCellRequest(ghost_data.target)
		GameEvents.ingame_board_eventer.emit_signal(
			"soldier_moved",
			IngameBoardEventer.SoldierMoved.new(ghost_data)
		)
	)

## broken soldier animation
const BROKEN_SOLDIER: PackedScene = preload("res://Objects/Soldiers/broken_soldier.tscn")
func BreakSoldier(at_cell: Vector2i) -> void:
	var broken_soldier: BrokenSoldier = BROKEN_SOLDIER.instantiate()
	broken_soldier.position = at_cell*64
	add_child(broken_soldier)

## moving soldier animation
const ANIMATED_SOLDIER: PackedScene = preload("res://Objects/Soldiers/moving_soldier.tscn")
func AnimateSoldier(from: Vector2i, to: Vector2i) -> MovingSoldier:
	var animated_soldier: MovingSoldier = ANIMATED_SOLDIER.instantiate()
	animated_soldier.SetProperties(from*64, to*64)
	movers.append(animated_soldier)
	add_child(animated_soldier)
	return animated_soldier
