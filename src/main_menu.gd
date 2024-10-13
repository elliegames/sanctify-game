extends Panel

@onready var light: Light2D = $Pattern/Light

var dark_theme: Theme
var light_theme: Theme

var dark = DisplayServer.is_dark_mode()

var gamepad_connected = false

func _ready():
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	
	dark_theme = preload("res://data/elementary_dark.theme")
	light_theme = preload("res://data/elementary_light.theme")
	
	if dark:
		theme = dark_theme
	else:
		theme = light_theme
		
	preload("res://arena.tscn")
	$VBoxContainer/PlayButton.grab_focus()


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

func set_arena_size(idx: int):
	ProjectSettings.set_setting("arena_size", idx)


func set_arena_theme(idx: int):
	ProjectSettings.set_setting("arena_theme", idx)


func begin():
	get_tree().change_scene_to_file("res://arena.tscn")

func _input(event: InputEvent) -> void:
	if not Input.get_connected_joypads().is_empty():
		gamepad_connected = true
		light.position = get_viewport_rect().size / 2
