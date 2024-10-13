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

func move(pos: Vector2i):
	if target_reach_timer <= 0.01:
		target_pos += pos
		target_reach_timer = 1
		
		
func start_cleansing():
	$CleansingAnimation.play("cleansing")

func start_losing():
	$CleansingAnimation.play("losing")
