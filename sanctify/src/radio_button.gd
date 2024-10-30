@tool
extends Button

class_name RadioButton

@export_category("Check Button")
@export var label: String
@export var main_icon: Texture2D

func _ready() -> void:
	_update()

func _process(delta: float) -> void:
	$HBoxContainer/CheckBox.button_pressed = button_pressed
	if Engine.is_editor_hint():
		_update()


func _update():
	$HBoxContainer/VBoxContainer/Label.text = label
	$HBoxContainer/VBoxContainer/TextureRect.texture = main_icon
	$HBoxContainer/CheckBox.button_pressed = button_pressed
	toggle_mode = true

func _uncheck():
	button_pressed = false
