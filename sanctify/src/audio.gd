extends Node

var _ducking = false

func start_music():
	$MainMenuThemeMusic.volume_db = -2;
	$MainMenuThemeMusic.play()
	
func duck_music():
	_ducking = true
	

func play_ui_accept_sound():
	$UIAcceptSound.play()
	
func _process(delta: float) -> void:
	if _ducking:
		$MainMenuThemeMusic.volume_db -= 5 * delta
		if $MainMenuThemeMusic.volume_db < -15:
			$MainMenuThemeMusic.stop()
			_ducking = false
