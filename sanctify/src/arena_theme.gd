extends Resource

class_name ArenaTheme

@export var place_name: String
@export var opponent: String

@export_group("Ambience")
@export var volumetric_color: Color
@export var sky: Sky
@export var ambient_sound_loop: AudioStream
@export_file var dust_particles: String

@export_group("Blocks")
@export_file var tile: String
@export_file var north_walls_inner_layer: String
@export_file var north_walls_inner_layer_alt: String
@export_file var north_walls_outer_layer: String
@export_file var north_walls_outer_layer_alt: String
@export_file var south_walls: String
@export_file var east_walls_inner_layer: String
@export_file var east_walls_inner_layer_alt: String
@export_file var east_walls_outer_layer: String
@export_file var east_walls_outer_layer_alt: String
@export_file var west_walls: String
@export_file var north_door: String
@export_file var south_door: String
@export_file var north_east_corner: String
@export_file var south_east_corner: String
@export_file var north_west_corner: String
@export_file var south_west_corner: String
