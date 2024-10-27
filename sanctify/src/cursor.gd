extends Node3D

class_name Cursor

var target_pos = Vector2i(0, 0)

var target_reach_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = position.lerp(Vector3(target_pos.x, 0.75, target_pos.y), delta * 5)

	if target_reach_timer > 0:
		target_reach_timer -= delta * 5

func move(pos: Vector2i, board):
	if target_reach_timer <= 0.01:
		board[target_pos.x][target_pos.y].show_highlight(false)
		target_pos += pos
		if not board[target_pos.x][target_pos.y].revealed:
			board[target_pos.x][target_pos.y].show_highlight(true)
			Input.start_joy_vibration(0, 0.2, 0, 0.1)
			$CursorMove.play()
		target_reach_timer = 1


func reveal_safe():
	$CleansingAnimation.play("reveal_safe")
	$RevealSafe.play()


func start_cleansing():
	$CleansingAnimation.play("cleansing")


func start_losing():
	$CleansingAnimation.play("losing")


func start_vibration(weak: float, strong: float, time: float):
	Input.start_joy_vibration(0, weak, strong, time)

func start_booting():
	$CleansingAnimation.play("booting")
