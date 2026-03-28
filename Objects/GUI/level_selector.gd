class_name LevelSelector
extends Control

signal new_game(data: LevelData)

var levels: Dictionary = {
	pages.CLASSIC: {
		"tag": "classic",
		"normal_levels": 3,
		"challenge_levels": 3,
		"difficulty": "res://Assets/Sprites/bones.png",
		"color": Color8(90, 90, 90, 255),
		"dark_color": Color8(60, 60, 60, 255),
		"moves": [1]
	},
	pages.CLASSIC_DIAGONALS: {
		"tag": "diagonal",
		"normal_levels": 3,
		"challenge_levels": 2,
		"difficulty": "res://Assets/Sprites/skull.png",
		"color": Color.YELLOW,
		"dark_color": Color.GOLD,
		"moves": [2, 1]
	},
	pages.STANDARD: {
		"tag": "standard",
		"normal_levels": 2,
		"challenge_levels": 1,
		"difficulty": "res://Assets/Sprites/angry_skull.png",
		"color": Color.BLUE,
		"dark_color": Color.DARK_BLUE,
		"moves": [3, 2, 1]
	}
}

enum pages {
	CLASSIC = 1,
	CLASSIC_DIAGONALS = 2,
	STANDARD = 3
}

var page: pages = pages.CLASSIC

func _ready() -> void:
	$VBoxContainer/HBoxContainer/Button2.pressed.connect(RequestPageChange.bind(1))
	$VBoxContainer/HBoxContainer/Button.pressed.connect(RequestPageChange.bind(-1))
	RequestPageChange(1)
	$VBoxContainer/Normals/Slot1/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"], 1)
	)
	$VBoxContainer/Normals/Slot2/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"], 2)
	)
	$VBoxContainer/Normals/Slot3/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"], 3)
	)
	
	$VBoxContainer/Challenges/Slot1/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"] + "_challenge", 1)
	)
	$VBoxContainer/Challenges/Slot2/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"] + "_challenge", 2)
	)
	$VBoxContainer/Challenges/Slot3/Button.pressed.connect(
		func(): OnSlotClicked(levels[page]["tag"] + "_challenge", 3)
	)
	

func ChangePage(new_page: pages) -> void:
	page = new_page
	for i in range(1, 4):
		var slot = get_node("VBoxContainer/Challenges/Slot" + str(i))
		slot.modulate = Color(0, 0, 0, 0)
	for i in range(1, 4):
		var slot = get_node("VBoxContainer/Normals/Slot" + str(i))
		slot.modulate = Color(0, 0, 0, 0)
	
	
	
	for level:int in range(levels[page]["normal_levels"], 0, -1):
		var slot = get_node("VBoxContainer/Normals/Slot" + str(level))
		slot.modulate = Color(1, 1, 1, 1)
		slot.get_node("RichTextLabel").text = LevelReader.ReadLevel(levels[page]["tag"] + "_" + str(level) + ".level").level_name
		slot.get_node("Level").texture = load("res://Levels/Main/" + levels[page]["tag"] + "_" + str(level) + ".png")
		
		for i:int in range(1, 4):
			slot.get_node("TextureRect" + str(i+1)).hide()
		for i:int in levels[page]["moves"]:
			slot.get_node("TextureRect" + str(i+1)).show()
		
		
	for challenge:int in range(levels[page]["challenge_levels"], 0, -1):
		var slot = get_node("VBoxContainer/Challenges/Slot" + str(challenge))
		
		slot.modulate = Color(1, 1, 1, 1)
		var panel_style: StyleBoxFlat = slot.get_node("Panel").get_theme_stylebox("panel")
		panel_style.bg_color = levels[page]["dark_color"]
		var button_style: StyleBoxFlat = slot.get_node("Button").get("theme_override_styles/normal")
		button_style.bg_color = levels[page]["color"]
		
		slot.get_node("Difficulty").texture = load(levels[page]["difficulty"])
		slot.get_node("RichTextLabel").text = LevelReader.ReadLevel(levels[page]["tag"] + "_challenge_" + str(challenge) + ".level").level_name
		slot.get_node("Level").texture = load("res://Levels/Main/" + levels[page]["tag"] + "_challenge_" + str(challenge) + ".png")
		
		for i:int in range(1, 4):
			slot.get_node("TextureRect" + str(i+1)).hide()
		for i:int in levels[page]["moves"]:
			slot.get_node("TextureRect" + str(i+1)).show()

func OnLevelChosen(data: LevelData) -> void:
	emit_signal("new_game", data)

func OnSlotClicked(preset: String, index: int) -> void:
	OnLevelChosen(LevelReader.ReadLevel(preset + "_" + str(index) + ".level"))

var page_count: int = 0
func RequestPageChange(dir: int) -> void:
	page_count += dir
	if page_count == 3:
		$VBoxContainer/HBoxContainer/Button2.modulate = Color(1, 1, 1, 0)
		$VBoxContainer/HBoxContainer/Button2.disabled = true
	else:
		$VBoxContainer/HBoxContainer/Button2.modulate = Color(1, 1, 1, 1)
		$VBoxContainer/HBoxContainer/Button2.disabled = false
	if page_count == 1:
		$VBoxContainer/HBoxContainer/Button.modulate = Color(1, 1, 1, 0)
		$VBoxContainer/HBoxContainer/Button.disabled = true
	else:
		$VBoxContainer/HBoxContainer/Button.modulate = Color(1, 1, 1, 1)
		$VBoxContainer/HBoxContainer/Button.disabled = false
	ChangePage(page_count)

func _on_button_3_pressed() -> void:
	GameEvents.gui_eventer.emit_signal("back")
