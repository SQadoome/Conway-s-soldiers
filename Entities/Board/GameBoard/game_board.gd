class_name IngameBoard
extends Node2D

var level_data: LevelData
var move_set: MoveSet

@export var object_canvas: CanvasLayer
@export var background: TileMapLayer
@export var camera: SmartCamera
@export var cell: Label


func _enter_tree() -> void:
	move_set = MoveSet.new();
	move_set.add_instruction(OrthogonalInstruction.new(Vector2.UP));
	move_set.add_instruction(OrthogonalInstruction.new(Vector2.DOWN));
	move_set.add_instruction(OrthogonalInstruction.new(Vector2.LEFT));
	move_set.add_instruction(OrthogonalInstruction.new(Vector2.RIGHT));
	BoardObjectManager.set_soldier_canvas(object_canvas.get_canvas());

func _process(delta: float) -> void:
	cell.text = str(TileUtil.cellurize_vector(get_global_mouse_position()));
	cell.position = get_global_mouse_position() - Vector2(0, 64)

func _ready() -> void:
	camera.camera_shifted.connect(_on_camera_shift)
	
	var huge: Callable = func():
		for x in 25:
			for y in 20:
				BoardObjectManager.create_soldier(Vector2(x, y))
				BoardObjectManager.create_soldier(Vector2(-x, y))
	
	var box: Callable = func():
		for x in 3:
			for y in 3:
				BoardObjectManager.create_soldier(Vector2(x, y))
	
	huge.call();
	

func _on_camera_shift(old_cell: Vector2, new_cell: Vector2) -> void:
	var shift_value: Vector2 = new_cell - old_cell
	background.position += TileUtil.vectorize_centered_cell(shift_value);
	

func load_level(data: LevelData) -> void:
	level_data = data;
	
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	await get_tree().process_frame;
	
	if (event.is_action_pressed(&"ui_accept")):
		
		var cell: Vector2 = TileUtil.cellurize_vector(get_global_mouse_position());
		if (BoardObjectManager.does_soldier_exist(cell)):
			clear_ghosts();
			var moves: Array[Move] = move_set.parse_moves(cell);
			create_ghosts(moves);
			
	if (event.is_action_pressed(&"ui_cancel")):
		clear_ghosts();
	


var ghosts: Array[GhostSoldier] = []
func clear_ghosts() -> void:
	for i:GhostSoldier in ghosts:
		if (not is_instance_valid(i)):
			continue;
		i.queue_free();
	ghosts.clear();
	

func create_ghosts(moves: Array[Move]) -> void:
	for i:Move in moves:
		var new_ghost: GhostSoldier = load("res://Entities/Board/BoardObjects/Soldiers/ghost_soldier.tscn").instantiate()
		new_ghost.set_props(i);
		object_canvas.add_child(new_ghost);
		ghosts.append(new_ghost);
		new_ghost.chosen.connect(play_move);
	

func break_soldiers(cells: PackedVector2Array) -> void:
	for i:Vector2 in cells:
		break_soldier(i);
	

func break_soldier(at_cell: Vector2) -> void:
	var broken_soldier: BrokenSoldier = GlobalAssets.BROKEN_SOLDIER.instantiate();
	broken_soldier.global_position = TileUtil.vectorize_cell(at_cell);
	object_canvas.add_child(broken_soldier);
	

func play_move(move: Move) -> void:
	BoardObjectManager.create_hidden_soldier(move.target_location);
	BoardObjectManager.destroy_soldiers(move.victims);
	
	break_soldiers(move.victims);
	break_soldier(move.origin);
	
	var anim_query := AnimationObjectQuery.new();
	anim_query.from = move.origin;
	anim_query.to = move.target_location;
	
	var animated_soldier: AnimatedObject = GlobalAssets.ANIMATED_SOLDIER.instantiate();
	animated_soldier.animate(anim_query);
	
	animated_soldier.finished.connect(func() -> void:
		BoardObjectManager.destroy_soldier(move.target_location)
		BoardObjectManager.create_soldier(move.target_location));
	
	object_canvas.add_child(animated_soldier);
	

#var ghosts: Array[GhostSoldier] = []
#var movers: Array[MovingSoldier] = []
#var activation_detectors: Dictionary[Vector2i, ActivationDetector] = {}
#
#var level_data: LevelData
#
#@export var internal_board: InfiniteInternal
#@export var line: Line
#@export var camera: SmartCamera
#@export var input_listener: BoardInput
#
#static var total_ascensions: int = 0
#static var ascension_count: int = 0
#static var instance: IngameBoard
#
#var background: Node2D
#
#func _enter_tree() -> void:
	#if (instance == null):
		#instance = self;
	#
	#total_ascensions = 0;
	#ascension_count = 0;
	#
	#input_listener.cell_clicked_left.connect(ValidateCellRequest);
	#input_listener.undo_request.connect(UndoLastMove);
	#
	#camera.camera_shifted.connect(shift_background);
	#camera.camera_shifted.connect(
		#func(old_cell: Vector2i, new_cell: Vector2i):
			#$Limit.position.x = (new_cell - old_cell).x*64 + 1920/2;
	#);
	#
	#for loc:Vector2i in level_data.ascensions:
		#PutAscend(loc);
	#
	#GameEvents.ingame_board_eventer.set_board(internal_board);
	#
	#GameEvents.ingame_board_eventer.reset.connect(func(): camera.SimulateShift(Vector2i(0, -35/2)));
	#GameEvents.ingame_board_eventer.ascension.connect(OnAscension);
	#
	#GameEvents.ingame_board_eventer.request_place_soldier.connect(internal_board.revive_soldier);
	#GameEvents.ingame_board_eventer.request_remove_soldier.connect(internal_board.erase_soldier);
	#GameEvents.ingame_board_eventer.request_soldier_move.connect(
		#func(from: Vector2, to: Vector2) -> void:
			#PlayMove(Move.new(from, to, [], {}));
	#);
	#
	#GameEvents.ingame_board_eventer.update_activation_detector.connect(update_activation_detector)
	#
	#background = Node2D.new();
	#for x in range(0, 35):
		#for y in range(-16, 16):
			#background.add_child(TileUtil.create_bg_tile(Vector2(-x, y)));
			#background.add_child(TileUtil.create_bg_tile(Vector2(x, y)));
	#background.z_index = -1
	#add_child(background);
	#
#
#func shift_background(old_cell: Vector2i, new_cell: Vector2i) -> void:
	#background.position = Vector2(new_cell*64) + Vector2(1920, 1080*2);
	#
#
#func _process(delta: float) -> void:
	#var cell: Vector2i = TileUtil.cellurize_vector(get_global_mouse_position() + Vector2(32, 32))
	#$Highlight.position = cell*64
	#if internal_board.does_soldier_exist(cell):
		#$Highlight.show()
	#else:
		#$Highlight.hide()
#
#var moves: Array[Move] = []
#var move_count: int = 0
#var move_pointer: int = 0
#func AddMove(move: Move) -> void:
	#moves.append(move)
	#move_count += 1
#
#func UndoLastMove() -> void:
	#if move_count <= 0:
		#return
	#move_count -= 1
	#
	#var move: Move = moves[move_count]
	#
	#internal_board.erase_soldier(move.target_location)
	#internal_board.revive_soldier(move.origin)
	#for victim:Vector2i in move.victims:
		#internal_board.revive_soldier(victim)
	#ValidateCellRequest(move.origin)
	#
	#GameEvents.ingame_board_eventer.emit_signal(
		#"undo_soldier_move",
		#IngameBoardEventer.UndoSoldierMove.new(moves[move_count])
	#)
	#moves.remove_at(move_count)
	#
#
#func ValidateCellRequest(cell: Vector2i) -> void:
	#for ghost:GhostSoldier in ghosts:
		#ghost.queue_free()
	#ghosts.clear()
	#if internal_board.does_soldier_exist(cell):
		#$Selection.position = cell*64
		#$Selection.show()
		#CreateGhosts(cell)
	#else:
		#$Selection.hide()
	#
#
#func PutAscend(at_cell: Vector2i) -> void:
	#var tile: AscendTile = GlobalAssets.ASCENSION_TILE.instantiate()
	#tile.position = at_cell*64
	#total_ascensions += 1
	#add_child(tile)
#
#func OnAscension(a: IngameBoardEventer.Ascension) -> void:
	#internal_board.erase_soldier(a.ascend_tile)
	#if internal_board.does_soldier_exist(a.hook_tile):
		#input_listener.DisableInput()
		#internal_board.erase_soldier(a.hook_tile)
		#AnimateSoldier(a.hook_tile, a.hook_tile + Vector2i.UP).finished.connect(
			#func():
				#internal_board.revive_soldier(a.hook_tile + Vector2i.UP)
				#input_listener.EnableInput()
		#)
#
#
#func CreateGhost(move: Move) -> void:
	#var ghost: GhostSoldier = GlobalAssets.GHOST_SOLDIER.instantiate()
	#ghost.SetProperties(move)
	#ghost.chosen.connect(PlayMove)
	#ghosts.append(ghost)
	#add_child(ghost)
#
#func CreateGhosts(cell: Vector2i) -> void:
	#var moves: Array[Move] = MoveGenerator.GenerateMoves(
		#cell,
		#level_data.move_set)
	#moves = MoveReader.ReadMoves(moves, internal_board.does_soldier_exist)
	#
	#for move:Move in moves:
		#CreateGhost(move)
#
#func PlayAudio(stream: AudioStream) -> void:
	#var player: AudioStreamPlayer = AudioStreamPlayer.new()
	#add_child(player)
	#player.finished.connect(player.queue_free)
	#player.stream = stream
	#player.play()
#
#const move_sfx: AudioStream = preload("res://Assets/Audio/MoveSound.mp3")
#func PlayMove(data: Move) -> void:
	#input_listener.DisableInput()
	#PlayAudio(move_sfx)
	#
	#AddMove(data)
	#
	#internal_board.erase_soldier(data.origin)
	#for victim:Vector2i in data.victims:
		#BreakSoldier(victim)
		#internal_board.erase_soldier(victim)
	#
	#var animated_soldier: MovingSoldier = AnimateSoldier(data.origin, data.target_location)
	#animated_soldier.finished.connect(func():
		#input_listener.EnableInput()
		#movers.erase(animated_soldier)
		#internal_board.revive_soldier(data.target_location)
		#
		#ValidateCellRequest(data.target_location)
		#GameEvents.ingame_board_eventer.soldier_moved.emit(data) 
		#
		#if activation_detectors.has(data.target_location):
			#activation_detectors[data.target_location].activate(data)
	#)
	#
#
#func BreakSoldier(at_cell: Vector2i) -> void:
	#var broken_soldier: BrokenSoldier = GlobalAssets.BROKEN_SOLDIER.instantiate()
	#broken_soldier.position = at_cell*64
	#add_child(broken_soldier)
#
#func AnimateSoldier(from: Vector2i, to: Vector2i) -> MovingSoldier:
	#var animated_soldier: MovingSoldier = GlobalAssets.ANIMATED_SOLDIER.instantiate()
	#animated_soldier.set_properties(from*64, to*64)
	#movers.append(animated_soldier)
	#add_child(animated_soldier)
	#return animated_soldier
#
#func update_activation_detector(detector: ActivationDetector) -> void:
	#activation_detectors.set(detector.tile, detector)
	#
#
#func get_cell_data(cell: Vector2) -> BoardCellData:
	#var data := BoardCellData.new();
	#data.tile = cell;
	#var object: Node2D = null;
	#
	#if (internal_board.does_soldier_exist(cell)):
		#object = internal_board.retrieve_soldier(cell);
		#return data;
	#if (activation_detectors.has(Vector2i(cell))):
		#object = activation_detectors[Vector2i(cell)];
	#
	#return data;
#
#func get_cells_data(cells: PackedVector2Array) -> Array[BoardCellData]:
	#var data: Array[BoardCellData] = [];
	#data.resize(cells.size());
	#var count: int = 0;
	#
	#for cell:Vector2 in cells:
		#data[count] = get_cell_data(cell);
		#count += 1;
	#
	#return data;
