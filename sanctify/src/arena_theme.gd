extends Resource

class_name ArenaTheme

@export var place_name: String
@export var opponent: String

@export_group("Scene")
@export var volumetric_color: Color
@export var ambient_color: Color
@export var backdrop_color: Color
@export var volumetric_backdrop_texture: Texture2D
@export var volumetric_backdrop_emission: Color
@export_range(0, 16) var volumetric_backdrop_energy: float
@export var volumetric_backdrop_height: float
@export var directional_light_left_color: Color
@export var directional_light_right_color: Color

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

@export_group("Audio")
@export var ambient_sound_loop: AudioStream
@export var game_lose_dialog: AudioStream
