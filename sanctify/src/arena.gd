extends Node3D

class_name Arena

@export var arena_themes: Array[ArenaTheme] = []
@export var arena_theme_index: int
var arena_theme: ArenaTheme

var grid_width = 9
var grid_length = 9
var mines = 8

var total_tiles = 0

var board = []
var max_flag_count = 0
var flag_count = 0
var lost = false
var board_init = false
var revealing_multi = false
var n_revealed = 0
var top_view = false
var timer_started = false
var time = 0
var game_over = false;

@export var input_enabled = false

@export var pulse_effect_strength: float = 0
@export var pulse_effect_radius: float = 0
var pulse_effect_center: Vector2

@onready var cursor: Cursor = $Cursor
@onready var ui: UI = $UI

# Called when the node enters the scene tree for the first time.
func _ready():
	arena_theme = arena_themes[arena_theme_index]

	ui.set_volumetric_color(arena_theme.volumetric_color)

	var arena_size_idx = ProjectSettings.get_setting("arena_size")
	if arena_size_idx == 0:
		grid_length = 8
		grid_width = 8
	elif arena_size_idx == 1:
		grid_length = 16
		grid_width = 8
	elif arena_size_idx == 2:
		grid_length = 16
		grid_width = 16
	elif arena_size_idx == 3:
		grid_length = 32
		grid_width = 16
	elif arena_size_idx == 4:
		grid_length = 32
		grid_width = 32

	mines = floor(grid_length * grid_length * 0.1)
	total_tiles = grid_length * grid_width
	max_flag_count = mines

	$IsoCam.set_priority(500)

	arrange_grid()
	arrange_environment()
	cursor.move(Vector2i(grid_length / 2, grid_width - 1), board)


func _physics_process(delta):
	if timer_started and not game_over:
		time += delta
		ui.update_time(time)

	if pulse_effect_strength > 0:
		for x in range(grid_length):
			for y in range(grid_width):
				var distance = (Vector2(x, y) - pulse_effect_center).length()
				var tile = board[x][y] as Tile
				if clamp(1 - abs(distance - pulse_effect_radius), 0, 1) > 0.5:
					tile.reveal_mine(lost)

				if lost:
					tile.get_parent().get_node("TileMesh").position.y = clamp(1 - abs(distance - pulse_effect_radius), 0, 1) * pulse_effect_strength


func _process(delta):
	if game_over or not input_enabled:
		return

	if Input.get_action_strength("cursor_joy_up") > 0.5:
		if cursor.target_pos.y > 0:
			cursor.move(Vector2(0, -1), board)
	elif Input.get_action_strength("cursor_joy_down") > 0.5:
		if cursor.target_pos.y < grid_width - 1:
			cursor.move(Vector2(0, 1), board)
	elif Input.get_action_strength("cursor_joy_left") > 0.5:
		if cursor.target_pos.x > 0:
			cursor.move(Vector2(-1, 0), board)
	elif Input.get_action_strength("cursor_joy_right") > 0.5:
		if cursor.target_pos.x < grid_length - 1:
			cursor.move(Vector2(1, 0), board)

	ui.update_flag(max_flag_count - flag_count, max_flag_count)

func _input(event):
	if game_over or not input_enabled:
		return

	var e = event as InputEvent

	if e.is_action("cursor_up"):
		if cursor.target_pos.y > 0:
			cursor.move(Vector2(0, -1), board)
	elif e.is_action("cursor_down"):
		if cursor.target_pos.y < grid_width - 1:
			cursor.move(Vector2(0, 1), board)
	elif e.is_action("cursor_left"):
		if cursor.target_pos.x > 0:
			cursor.move(Vector2(-1, 0), board)
	elif e.is_action("cursor_right"):
		if cursor.target_pos.x < grid_length - 1:
			cursor.move(Vector2(1, 0), board)

	if e.is_action_pressed("cursor_flag"):
		(board[cursor.target_pos.x][cursor.target_pos.y] as Tile).flag()
	elif e.is_action_pressed("cursor_reveal"):
		var tile = board[cursor.target_pos.x][cursor.target_pos.y] as Tile
		if not revealing_multi:
			reveal_recursive(tile.board_pos)

	if e.is_action_pressed("switch_view"):
		switch_view()
	elif e.is_action_pressed("give_up"):
		ui.give_up()


func arrange_grid():
	if len(arena_themes) == 0:
		return

	var tile_resource = load(arena_theme.tile)

	total_tiles = grid_length * grid_width

	board = []
	for x in range(grid_length):
		var row = []
		for z in range(grid_width):
			var tile_instance = tile_resource.instantiate()  # Create an instance of the tile scene
			row.append(tile_instance.get_node("Tile") as Tile)
			# Set the tile's position in the grid
			var _position = Vector3(
				x,  # X-position based on grid column
				0,  # Y-position (you can change this if you want to stack tiles)
				z   # Z-position based on grid row
			)
			tile_instance.position = _position
			tile_instance.get_node("Tile").board_pos = Vector2i(x, z)

			# Add the tile to the scene
			add_child(tile_instance)
		board.append(row)
	set_cosmetics()


func arrange_mines(exc: Vector2i):
	board_init = true
	var m = 0
	while m < mines:
		var i = randi_range(0, grid_length - 1)
		var j = randi_range(0, grid_width - 1)

		if i == exc.x and j == exc.y:
			continue

		if not (board[i][j] as Tile).is_mine:
			(board[i][j] as Tile).is_mine = true
			m += 1


func set_cosmetics():
	var p = 0
	var max_puddles = grid_length * grid_width * 0.01
	while p < max_puddles:
		var i = randi_range(0, grid_length - 1)
		var j = randi_range(0, grid_width - 1)

		if (board[i][j] as Tile).show_imperfection():
			p += 1

	var max_smoke = grid_width * 0.3
	p = 0
	while p < max_smoke:
		var j = randi_range(0, grid_width - 1)

		if (board[2][j] as Tile).show_smoke(grid_length * 14 / 9):
			p += 1


func reveal_recursive(start_position: Vector2i):
	cursor.reveal_safe()
	const matrix = [[-1, 0], [1, 0], [0, -1], [0, 1]]
	if not timer_started:
			timer_started = true

	var queue = []

	if (board[start_position.x][start_position.y] as Tile).is_mine:
		print("YOU LOST")
		$EndCam.set_priority(1000)
		cursor.start_losing()
		game_over = true
		lost = true
		$Audio/GameLostDialog.play()
		start_ripple_effects((board[start_position.x][start_position.y] as Tile).board_pos, true)
		ui.lose(arena_theme.opponent + "'curse has been triggered. The Pantheon has been destroyed", total_tiles - n_revealed)
		return
	else:
		(board[start_position.x][start_position.y] as Tile).show_highlight(false)

	# Add the first clicked cell to the queue
	queue.append(start_position)
	revealing_multi = true
	
	if (board[start_position.x][start_position.y] as Tile).get_nearby_mines() == 0:
		$Audio/RevealMany.play()

	while queue.size() > 0:
		var current_pos = queue.pop_front()
		var x = current_pos.x
		var y = current_pos.y

		if x < 0 or x >= grid_length or y < 0 or y >= grid_width:
			continue

		var tile = board[x][y] as Tile
		# Skip if this cell is out of bounds or already revealed
		if tile.revealed or tile.is_mine:
			if tile.is_mine:
				print("Is mine")
			else:
				tile.update_hint()
			continue

		tile.reveal()
		n_revealed += 1

		if n_revealed + mines == total_tiles:
			print("GAMEOVER: YOU WON")
			game_over = true
			cursor.start_cleansing()
			tile.show_cleansing_anim()
			start_ripple_effects(tile.board_pos, false)
			ui.win("You have cleansed the divine pantheon. " + arena_theme.opponent + "'s curse has been lifted!", time)
			$EndCam.set_priority(1000)

		if tile.get_nearby_mines() > 0:
			continue

		# Otherwise, add all neighboring cells to the queue to reveal them
		for m in matrix:
			var neighbor_pos = Vector2(x + m[0], y + m[1])
			# Add the neighbor to the queue for further processing
			queue.append(neighbor_pos)

	revealing_multi = false


func switch_view():
	top_view = !top_view
	if top_view:
		$IsoCam.set_priority(0)
		$TopCam.set_priority(10)
		$Camera3D/DOF.visible = false
	else:
		$IsoCam.set_priority(10)
		$TopCam.set_priority(0)
		$Camera3D/DOF.visible = true


func arrange_environment():
	var north_wall_inner_res: Resource = null
	var north_wall_inner_alt_res: Resource = null
	var north_wall_outer_res: Resource = null
	var north_wall_outer_alt_res: Resource = null
	var south_wall_res: Resource = null
	var east_wall_inner_res: Resource = null
	var east_wall_inner_alt_res: Resource = null
	var east_wall_outer_res: Resource = null
	var east_wall_outer_alt_res: Resource = null
	var west_wall_res: Resource = null
	var north_door_res: Resource = null
	var south_door_res: Resource = null
	var north_east_corner_res: Resource = null
	var south_east_corner_res: Resource = null
	var north_west_corner_res: Resource = null
	var south_west_corner_res: Resource = null


	if ResourceLoader.exists(arena_theme.north_walls_inner_layer):
		north_wall_inner_res = load(arena_theme.north_walls_inner_layer)

	if ResourceLoader.exists(arena_theme.north_walls_inner_layer_alt):
		north_wall_inner_alt_res = load(arena_theme.north_walls_inner_layer_alt)

	if ResourceLoader.exists(arena_theme.north_walls_outer_layer):
		north_wall_outer_res = load(arena_theme.north_walls_outer_layer)

	if ResourceLoader.exists(arena_theme.north_walls_outer_layer_alt):
		north_wall_outer_alt_res = load(arena_theme.north_walls_outer_layer_alt)

	if ResourceLoader.exists(arena_theme.east_walls_inner_layer):
		east_wall_inner_res = load(arena_theme.east_walls_inner_layer)

	if ResourceLoader.exists(arena_theme.east_walls_inner_layer_alt):
		east_wall_inner_alt_res = load(arena_theme.east_walls_inner_layer_alt)

	if ResourceLoader.exists(arena_theme.east_walls_outer_layer):
		east_wall_outer_res = load(arena_theme.east_walls_outer_layer)

	if ResourceLoader.exists(arena_theme.east_walls_outer_layer_alt):
		east_wall_outer_alt_res = load(arena_theme.east_walls_outer_layer_alt)

	if ResourceLoader.exists(arena_theme.west_walls):
		west_wall_res = load(arena_theme.west_walls)

	if ResourceLoader.exists(arena_theme.south_walls):
		south_wall_res = load(arena_theme.south_walls)

	if ResourceLoader.exists(arena_theme.north_door):
		north_door_res = load(arena_theme.north_door)

	if ResourceLoader.exists(arena_theme.south_door):
		south_door_res = load(arena_theme.south_door)

	if ResourceLoader.exists(arena_theme.north_east_corner):
		north_east_corner_res = load(arena_theme.north_east_corner)

	if ResourceLoader.exists(arena_theme.north_west_corner):
		north_west_corner_res = load(arena_theme.north_west_corner)

	if ResourceLoader.exists(arena_theme.south_east_corner):
		south_east_corner_res = load(arena_theme.south_east_corner)

	if ResourceLoader.exists(arena_theme.south_west_corner):
		south_west_corner_res = load(arena_theme.south_west_corner)

	# Make east inner wall
	if east_wall_inner_res != null:
		if east_wall_inner_alt_res != null:
			var alt = false
			for y in range(grid_width):
				alt = !alt
				if not alt:
					var east_inner_layer = east_wall_inner_res.instantiate()
					east_inner_layer.position = Vector3(-1, 0, y)
					add_child(east_inner_layer)
				else:
					var east_inner_layer_alt = east_wall_inner_alt_res.instantiate()
					east_inner_layer_alt.position = Vector3(-1, 0, y)
					add_child(east_inner_layer_alt)
		else:
			for y in range(grid_width):
				var east_inner_layer = east_wall_inner_res.instantiate()
				east_inner_layer.position = Vector3(-1, 0, y)
				add_child(east_inner_layer)

	# Make east outer wall
	if east_wall_outer_res != null:
		if east_wall_outer_alt_res != null:
			var alt = false
			for y in range(grid_width):
				alt = !alt
				if not alt:
					var east_outer_layer = east_wall_outer_res.instantiate()
					east_outer_layer.position = Vector3(-2, 0, y)
					add_child(east_outer_layer)
				else:
					var east_outer_layer_alt = east_wall_outer_alt_res.instantiate()
					east_outer_layer_alt.position = Vector3(-2, 0, y)
					add_child(east_outer_layer_alt)
		else:
			for y in range(grid_width):
				var east_outer_layer = east_wall_outer_res.instantiate()
				east_outer_layer.position = Vector3(-2, 0, y)
				add_child(east_outer_layer)

	# Make west wall
	if west_wall_res != null:
		for y in range(grid_width):
			var west_wall_layer = west_wall_res.instantiate()
			west_wall_layer.position = Vector3(grid_length, 0, y)
			add_child(west_wall_layer)

	# Make south wall
	if south_wall_res != null:
		if south_door_res != null:
			for x in range(grid_length):
				if x != int(grid_length / 2):
					var south_wall = south_wall_res.instantiate()
					south_wall.position = Vector3(x, 0, grid_width)
					south_wall.rotate_y(-PI / 2)
					add_child(south_wall)
				else:
					var south_door = south_door_res.instantiate()
					south_door.position = Vector3(x, 0, grid_width)
					south_door.rotate_y(-PI / 2)
					add_child(south_door)
		else:
			for x in range(grid_length):
				var south_wall = south_wall_res.instantiate()
				south_wall.position = Vector3(x, 0, grid_width)
				south_wall.rotate_y(-PI / 2)
				add_child(south_wall)

	# Make north outer wall
	if north_wall_outer_res != null:
		if north_wall_outer_alt_res != null:
			var alt = false
			for x in range(grid_length):
				alt = !alt
				if not alt:
					var north_outer_layer = north_wall_outer_res.instantiate()
					north_outer_layer.position = Vector3(x, 0, -2)
					north_outer_layer.rotate_y(-PI / 2)
					add_child(north_outer_layer)
				else:
					var north_outer_layer_alt = north_wall_outer_alt_res.instantiate()
					north_outer_layer_alt.position = Vector3(x, 0, -2)
					north_outer_layer_alt.rotate_y(-PI / 2)
					add_child(north_outer_layer_alt)
		else:
			for x in range(grid_length):
				var north_outer_layer = north_wall_outer_res.instantiate()
				north_outer_layer.position = Vector3(x, 0, -2)
				north_outer_layer.rotate_y(-PI / 2)
				add_child(north_outer_layer)

	# Make north inner wall
	if north_wall_inner_res != null:
		if north_door_res != null:
			for x in range(grid_length):
				if x == int(grid_length / 2):
					var north_door = north_door_res.instantiate()
					north_door.position = Vector3(x, 0, -1)
					north_door.rotate_y(-PI / 2)
					add_child(north_door)
				elif north_wall_inner_alt_res != null:
					if fmod(x, 2) != 0:
						var north_wall_inner = north_wall_inner_alt_res.instantiate()
						north_wall_inner.position = Vector3(x, 0, -1)
						north_wall_inner.rotate_y(-PI / 2)
						add_child(north_wall_inner)
					else:
						var north_wall = north_wall_inner_res.instantiate()
						north_wall.position = Vector3(x, 0, -1)
						north_wall.rotate_y(-PI / 2)
						add_child(north_wall)
				else:
					var north_wall = north_wall_inner_res.instantiate()
					north_wall.position = Vector3(x, 0, -1)
					north_wall.rotate_y(-PI / 2)
					add_child(north_wall)
		else:
			if north_wall_outer_alt_res != null:
				var alt = true
				for x in range(grid_length):
					alt = !alt
					if not alt:
						var north_outer_layer = north_wall_outer_res.instantiate()
						north_outer_layer.position = Vector3(x, 0, -2)
						north_outer_layer.rotate_y(-PI / 2)
						add_child(north_outer_layer)
					else:
						var north_outer_layer_alt = north_wall_outer_alt_res.instantiate()
						north_outer_layer_alt.position = Vector3(x, 0, -2)
						north_outer_layer_alt.rotate_y(-PI / 2)
						add_child(north_outer_layer_alt)
			else:
				for x in range(grid_length):
					var north_outer_layer = north_wall_outer_res.instantiate()
					north_outer_layer.position = Vector3(x, 0, -2)
					north_outer_layer.rotate_y(-PI / 2)
					add_child(north_outer_layer)

	# Make north-east corner
	if north_east_corner_res != null:
		var north_east_corner = north_east_corner_res.instantiate()
		north_east_corner.position = Vector3(-1, 0, -1)
		add_child(north_east_corner)

	# Make north-west corner
	if north_west_corner_res != null:
		var north_west_corner = north_west_corner_res.instantiate()
		north_west_corner.position = Vector3(grid_length, 0, -1)
		add_child(north_west_corner)

	# Make south-west corner
	if south_west_corner_res != null:
		var south_west_corner = south_west_corner_res.instantiate()
		south_west_corner.position = Vector3(grid_length, 0, grid_width)
		south_west_corner.rotate_y(-PI / 2)
		add_child(south_west_corner)

	# Make south-east corner
	if south_east_corner_res != null:
		var south_east_corner = south_east_corner_res.instantiate()
		south_east_corner.position = Vector3(-1, 0, grid_width)
		south_east_corner.rotate_y(-PI / 2)
		add_child(south_east_corner)

	$ReflectionProbe.size = Vector3(grid_length + 3, 30, grid_width + 3)
	$ReflectionProbe.position = Vector3((grid_length + 2) / 2, 0, (grid_width + 2) / 2)
	
	# Place the priestess
	$Priestess.position = Vector3(grid_length / 2, 1, grid_width + 2)
	$CharacterGlow.position = Vector3(grid_length / 2, 1, grid_width + 2)
	$AnimationTimer.start()
	$AnimationPlayer.play("begin")

func start_ripple_effects(center: Vector2i, destroy: bool):
	pulse_effect_center = Vector2(center.x, center.y)
	if destroy:
		$AnimationPlayer.play("destruct")
	else:
		$AnimationPlayer.play("cleanse")

func play_intro_cutscene():
	$Priestess/AnimationTree.set("parameters/conditions/start", true)
	cursor.start_booting()
