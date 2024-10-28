extends Area3D

class_name Tile

var nearby_mines = 0
var revealed = false
var is_mine = false

var board_pos: Vector2i

@onready var arena: Arena = get_parent().get_parent()

@export var tile_mesh: MeshInstance3D
@export var flag_node: Node3D
@export var fog: Node3D
@export var imperfection: Node3D
@export var smoke: GPUParticles3D
@export var fog_dark: bool
@export var selection_box: Node3D
@export var animator: AnimationPlayer
@export var cleansing_light: Node3D
var runes: Array[Decal]

# Called when the node enters the scene tree for the first time.
func _ready():
	fog.visible = fog_dark
	runes.append(null)
	runes.append($RuneDecals/Rune1)
	runes.append($RuneDecals/Rune2)
	runes.append($RuneDecals/Rune3)
	runes.append($RuneDecals/Rune4)
	runes.append($RuneDecals/Rune5)
	runes.append($RuneDecals/Rune6)
	runes.append($RuneDecals/Rune7)
	tile_mesh.get_surface_override_material(0).set("albedo_color",  Color("#fff").blend(Color("#000", randf_range(0.0, 0.2))))
	tile_mesh.rotate_y(randi_range(1, 4) * PI / 2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func mouse_input(camera, event, event_position, normal, shape_idx):
	if (event as InputEvent).is_action_released("reveal"):
		if not arena.revealing_multi:
			arena.reveal_recursive(board_pos)
	if (event as InputEvent).is_action_released("flag"):
		flag()


func reveal():
	if not arena.board_init:
		arena.arrange_mines(board_pos)

	if not arena.lost and is_mine:
		arena.lost = true
	else:
		revealed = true
		flag_node.visible = false
		if fog != null:
			fog.visible = false
		nearby_mines = get_nearby_mines()
		update_hint()

func update_hint():
	for i in range(1, 7):
			if i == nearby_mines:
				runes[i].visible = true
			else:
				runes[i].visible = false

func flag():
	if flag_node == null:
		return

	if flag_node.visible:
		flag_node.visible = !fog_dark
		arena.flag_count -= 1
	elif arena.flag_count < arena.max_flag_count and not revealed:
		flag_node.visible = fog_dark
		arena.flag_count += 1


func get_nearby_mines():
	var count = 0

	# Loop through all the neighboring cells (including diagonals)
	for dx in range(-1, 2):  # -1, 0, 1
		for dy in range(-1, 2):  # -1, 0, 1
			# Skip the current cell itself
			if dx == 0 and dy == 0:
				continue

			var neighbor_x = board_pos.x + dx
			var neighbor_y = board_pos.y + dy

			# Check bounds to avoid accessing out-of-bounds array indices
			if neighbor_x >= 0 and neighbor_x < arena.grid_length and neighbor_y >= 0 and neighbor_y < arena.grid_width:
				if (arena.board[neighbor_x][neighbor_y] as Tile).is_mine:
					count += 1

	return count

func show_imperfection():
	if imperfection == null:
		return true

	if imperfection.visible:
		return false

	imperfection.visible = true
	return true

func show_smoke(life_time = 14):
	if smoke == null:
		return true

	if smoke.emitting:
		return false

	smoke.emitting = true
	smoke.lifetime = life_time
	return true

func reveal_mine(destroy=true):
	fog.visible = false
	selection_box.visible = false
	selection_box.visible = false
	if destroy and is_mine:
		animator.play("reveal_curse")
	elif is_mine:
		cleansing_light.visible = true
		
		
func show_cleansing_anim():
	animator.play("cleanse")
	
func show_reveal_animation():
	animator.play("reveal")

func show_highlight(show: bool):
	selection_box.visible = show
