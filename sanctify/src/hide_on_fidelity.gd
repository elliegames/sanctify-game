extends Node

@export_range(1, 2, 1) var fidelity_threshold: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	var fidelity = ProjectSettings.get_setting("gfx_fidelity")
	if fidelity < fidelity_threshold:
		parent.hide()
