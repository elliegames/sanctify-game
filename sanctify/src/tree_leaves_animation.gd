extends Node

@export var leaves: Array[Node3D] = []
@export var noise: Noise

@export var apples: Array[Node3D] = []

var leaf_locations: Array[Vector3]
@onready var noise_index = 0

func _ready() -> void:	
	leaf_locations = []
	for i in range(len(leaves)):
		leaf_locations.push_front(leaves[i].position)
		
	for i in range(len(apples)):
		var anim_player = apples[i].get_node("AnimationPlayer") as AnimationPlayer
		anim_player.play("oscillate")
		anim_player.speed_scale = randf_range(0.2, 1.0)

func _physics_process(delta: float) -> void:
	if noise != null:
		for i in range(len(leaves)):
			leaves[i].position = leaf_locations[i] + Vector3.LEFT * noise.get_noise_1d(noise_index - i) * 0.5
	
		if noise_index > 4294967295:
			noise_index = 0

		noise_index += delta * 2
