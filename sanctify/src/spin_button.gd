extends Control

class_name SpinButton

@export var value: int = 7
@export var lower_limit: int = 7
@export var upper_limit: int = 36

signal changed(value: int)

@onready var text: TextEdit = $TextEdit

func _ready() -> void:
	text.text = str(value)


func increment():
	if value < upper_limit:
		value += 1
		changed.emit(value)
		text.text = str(value)

func decrement():
	if value > lower_limit:
		value -= 1
		changed.emit(value)
		text.text = str(value)
