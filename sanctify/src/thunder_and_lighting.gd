extends Node

@onready var thunders = [$Thunder1 as AudioStreamPlayer, $Thunder2 as AudioStreamPlayer]
func random_thunder():
	$ThunderTimer.wait_time = randf_range(8, 15)
	var thunder = thunders.pick_random() as AudioStreamPlayer
	thunder.pitch_scale = randf_range(0.5, 1.5)
	thunder.play()
	$ThunderTimer.start()


func random_lighting():
	$LightingTimer.wait_time = randf_range(0.2, 2)
	$Lightning.light_energy = randf_range(0.5, 2)
	$Lightning.visible = true
	$Lightning/LightingOffTimer.start()
	$LightingTimer.start()
	
func lighting_off():
	$Lightning.visible = false
