extends Control

class_name LoadingScreen

@onready var dark = DisplayServer.is_dark_mode()

var animation_wait = 0

func _process(delta: float) -> void:
	if DisplayServer.is_dark_mode() != dark:
		dark = DisplayServer.is_dark_mode()
		if dark:
			$Center/Panel/LoadingSpinner.flip_h = false
		else:
			$Center/Panel/LoadingSpinner.flip_h = true
			
	if animation_wait > 0.04:
		animation_wait = 0
		if dark:
			$Center/Panel/LoadingSpinner.rotation_degrees = $Center/Panel/LoadingSpinner.rotation_degrees + 15
		else:
			$Center/Panel/LoadingSpinner.rotation_degrees = $Center/Panel/LoadingSpinner.rotation_degrees - 15
	else:
		animation_wait = animation_wait + delta

func animate_in():
	$AnimationPlayer.play("animate_in")

func animate_out():
	$AnimationPlayer.play("animate_out")
