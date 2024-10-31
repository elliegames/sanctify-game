extends Panel

@onready var light: Light2D = $Pattern/Light

var dark_theme: Theme
var light_theme: Theme

var dark = DisplayServer.is_dark_mode()

var gamepad_connected = false
var loading = false

func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	
	dark_theme = preload("res://data/elementary_dark.theme")
	light_theme = preload("res://data/elementary_light.theme")
	
	if dark:
		theme = dark_theme
		$Pattern/Light.color = Color.WHITE
	else:
		theme = light_theme
		$Pattern/Light.color = Color("#fff4")
		
	preload("res://arena.tscn")
	preload("res://prefabs/ui.tscn")
	preload("res://prefabs/priestess.tscn")
	$VBoxContainer/PlayButton.grab_focus()
	$LoadingScreen.visible = false
	Audio.start_music()
	load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not gamepad_connected:
		var pos = get_viewport().get_mouse_position()
		light.position = pos
	
	if DisplayServer.is_dark_mode() != dark:
		dark = DisplayServer.is_dark_mode()
		if dark:
			theme = dark_theme
			$Pattern/Light.color = Color.WHITE
		else:
			theme = light_theme
			$Pattern/Light.color = Color("#fff4")
			
	if loading:
		Audio.duck_music()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit() # default behavior


func set_arena_size(idx: int):
	play_ui_accept_sound()
	var grid_length = 7
	var grid_width = 7
	if idx == 0:
		grid_length = 7
		grid_width = 7
	elif idx == 1:
		grid_length = 9
		grid_width = 9
	elif idx == 2:
		grid_length =17
		grid_width = 9
	elif idx == 3:
		grid_length = 17
		grid_width = 17
	elif idx == 4:
		grid_length = 27
		grid_width = 17
	$VBoxContainer/CustomSizeBox.visible = idx == 5
	ProjectSettings.set_setting("grid_length", grid_length)
	ProjectSettings.set_setting("grid_width", grid_width)


func validate_number(value: String) -> int:
	if value.is_valid_int():
		return int(value)
	
	return -1


func set_grid_length():
	var text_field = $VBoxContainer/CustomSizeBox/HBoxContainer/GridLength as TextEdit
	var value = text_field.text
	if value.length() == 0:
		return
	
	var val = validate_number(value)
	
	if val < 0:
		text_field.text = value.erase(value.length() - 1)
		
func set_grid_width():
	var text_field = $VBoxContainer/CustomSizeBox/HBoxContainer/GridWidth as TextEdit
	var value = text_field.text
	if value.length() == 0:
		return
	
	var val = validate_number(value)
	if val < 0:
		text_field.text = value.erase(value.length() - 1)

func check_grid_length():
	var text_field = $VBoxContainer/CustomSizeBox/HBoxContainer/GridLength as TextEdit
	var value = int(text_field.text)
	if value < 7 or value > 32: 
		text_field.text = ProjectSettings.get_setting("grid_length")
	else:
		ProjectSettings.set_setting("grid_length", value)


func check_grid_width():
	var text_field = $VBoxContainer/CustomSizeBox/HBoxContainer/GridWidth as TextEdit
	var value = int(text_field.text)
	if value < 7 or value > 32: 
		text_field.text = ProjectSettings.get_setting("grid_width")
	else:
		ProjectSettings.set_setting("grid_width", value)


func set_difficulty(idx: int):
	ProjectSettings.set_setting("difficulty", idx)
	play_ui_accept_sound()


func set_arena_theme(idx: int):
	ProjectSettings.set_setting("arena_theme", idx)
	play_ui_accept_sound()


func play_ui_accept_sound():
	Audio.play_ui_accept_sound()

func begin():
	$LoadingScreen.animate_in()
	$LoadTimer.start()
	loading = true
	preload("res://prefabs/cursor.tscn")

func load_arena():
	save_settings()
	get_tree().change_scene_to_file("res://arena.tscn")

func _input(event: InputEvent) -> void:
	if not Input.get_connected_joypads().is_empty():
		gamepad_connected = true
		light.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 3)

func save_settings():
	var settings_dict = {
		"grid_length": ProjectSettings.get_setting("grid_length"),
		"grid_width": ProjectSettings.get_setting("grid_width"),
		"difficulty": ProjectSettings.get_setting("difficulty"),
		"arena_theme": ProjectSettings.get_setting("arena_theme")
	}
	print("Saving: ", settings_dict)
	var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	settings_file.store_line(JSON.stringify(settings_dict))
	
func load_settings():
	if not FileAccess.file_exists("user://settings.json"):
		$VBoxContainer/CustomSizeBox/HBoxContainer/GridLength.text = "7"
		ProjectSettings.set_setting("grid_length", 7)
		$VBoxContainer/CustomSizeBox/HBoxContainer/GridWidth.text = "7"
		ProjectSettings.set_setting("grid_width", 7)
		$VBoxContainer/ArenaSizeSelect.select(0)
		ProjectSettings.set_setting("difficulty", 0)
		ProjectSettings.set_setting("arena_theme", 0)
		ProjectSettings.set_setting("first_time", true)
	else:
		var settings_file = FileAccess.open("user://settings.json", FileAccess.READ)
		var settings_buffer = settings_file.get_line()
		var settings = JSON.parse_string(settings_buffer)
		print("Loading: ", settings)
		var _grid_length = settings["grid_length"]
		var _grid_width = settings["grid_width"]
		
		if _grid_length == 7 and _grid_width == 7:
			$VBoxContainer/ArenaSizeSelect.select(0)
		elif _grid_length == 9 and _grid_width == 9:
			$VBoxContainer/ArenaSizeSelect.select(1)
		elif _grid_length == 17 and _grid_width == 9:
			$VBoxContainer/ArenaSizeSelect.select(2)
		elif _grid_length == 17 and _grid_width == 17:
			$VBoxContainer/ArenaSizeSelect.select(3)
		elif _grid_length == 27 and _grid_width == 17:
			$VBoxContainer/ArenaSizeSelect.select(4)
		else:
			$VBoxContainer/CustomSizeBox.visible = true
			$VBoxContainer/ArenaSizeSelect.select(5)
			$VBoxContainer/CustomSizeBox/HBoxContainer/GridLength.text = str(_grid_length)
			
			$VBoxContainer/CustomSizeBox/HBoxContainer/GridWidth.text = str(_grid_width)

		ProjectSettings.set_setting("grid_length", _grid_length)
		ProjectSettings.set_setting("grid_width", _grid_width)
		
		var _difficulty = int(settings["difficulty"])
		if _difficulty == 0:
			$VBoxContainer/DifficultyBox/EasyButton.button_pressed = true
			$VBoxContainer/DifficultyBox/MediumButton.button_pressed = false
			$VBoxContainer/DifficultyBox/HardButton.button_pressed = false
		elif _difficulty == 1:
			$VBoxContainer/DifficultyBox/EasyButton.button_pressed = false
			$VBoxContainer/DifficultyBox/MediumButton.button_pressed = true
			$VBoxContainer/DifficultyBox/HardButton.button_pressed = false
		else:
			$VBoxContainer/DifficultyBox/EasyButton.button_pressed = false
			$VBoxContainer/DifficultyBox/MediumButton.button_pressed = false
			$VBoxContainer/DifficultyBox/HardButton.button_pressed = true
		ProjectSettings.set_setting("difficulty", _difficulty)
		$VBoxContainer/ArenaThemeSelect.select(settings["arena_theme"])
		ProjectSettings.set_setting("arena_theme", settings["arena_theme"])
		ProjectSettings.set_setting("first_time", false)

func quit():
		save_settings()
		get_tree().quit()
