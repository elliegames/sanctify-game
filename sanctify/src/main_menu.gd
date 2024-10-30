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
	else:
		theme = light_theme
		
	preload("res://arena.tscn")
	preload("res://prefabs/ui.tscn")
	preload("res://prefabs/priestess.tscn")
	$VBoxContainer/PlayButton.grab_focus()
	$LoadingScreen.visible = false
	Audio.start_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not gamepad_connected:
		var pos = get_viewport().get_mouse_position()
		light.position = pos
	
	if DisplayServer.is_dark_mode() != dark:
		dark = DisplayServer.is_dark_mode()
		if dark:
			theme = dark_theme
		else:
			theme = light_theme
			
	if loading:
		Audio.duck_music()

func set_arena_size(idx: int):
	ProjectSettings.set_setting("arena_size", idx)
	$VBoxContainer/CustomSizeBox.visible = idx == 5


func set_arena_theme(idx: int):
	ProjectSettings.set_setting("arena_theme", idx)

func play_ui_accept_sound():
	Audio.play_ui_accept_sound()

func begin():
	$LoadingScreen.animate_in()
	$LoadTimer.start()
	loading = true
	preload("res://prefabs/cursor.tscn")

func load_arena():
	get_tree().change_scene_to_file("res://arena.tscn")

func _input(event: InputEvent) -> void:
	if not Input.get_connected_joypads().is_empty():
		gamepad_connected = true
		light.position = get_viewport_rect().size / 2
