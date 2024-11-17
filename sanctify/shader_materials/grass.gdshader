shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap;

uniform sampler2D distribution_noise;
uniform float distribution_scale = 0.5;

uniform float sway = 1.14;
uniform float sway_pow = 1.3;
uniform float grass_roughness = 0.3;
uniform float sway_noise_sampeling_scale = 0.12;
uniform float sway_time_scale = 0.2;
uniform vec3 sway_dir = vec3(1.0,0.0,1.0);
uniform sampler2D sway_noise; //noise with with and height 1000
uniform float color_scale = 0.3;
uniform float color_grad_height = -0.5;
uniform vec4 top_color : source_color;
uniform vec4 bot_color : source_color;
uniform vec3 grass_scale = vec3(1.0,1.0,1.0);

uniform float character_radius = 0.2;
uniform sampler2D character_distance_falloff_curve : hint_default_black;
uniform float character_push_strength = 1.0;
instance uniform vec3 cursor_position;

varying vec3 vert;
varying float current_wind;

float sclamp(float f,float sc){
	return clamp(((f-0.5)*sc)+0.5,0.0,1.0);
}

void fragment()
{
	ALBEDO = mix(bot_color,top_color,(vert.y+color_grad_height)*color_scale).xyz;
	NORMAL *= FRONT_FACING ? 1.0 : -1.0;
	SPECULAR = 0.5;
	ROUGHNESS = clamp(1.0-(sclamp(current_wind,0.8)*grass_roughness),0.2,1);
}

void vertex()
{
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec2 distribution_uv = world_vertex.xz * distribution_scale;

	float dist = 1.0 - texture(distribution_noise, distribution_uv).r;

	VERTEX *= grass_scale;
	VERTEX.y *= dist;
	vert = VERTEX;
	NORMAL = vec3(0.0,1.0,0.0);
	vec4 sway_dir_local = vec4(sway_dir,0.0) * MODEL_MATRIX;

	current_wind = texture(sway_noise,normalize(sway_dir.xz) * (-TIME*sway_time_scale) + world_vertex.xz*vec2(sway_noise_sampeling_scale)).x;
	current_wind = 0.25 + 0.75 * current_wind;
	VERTEX += normalize(sway_dir_local.xyz) * sway * (VERTEX.y) * current_wind;

	vec3 dir_to_character = cursor_position - MODEL_MATRIX[3].xyz;
	// uncomment the following line to have a horizontal only character push
//	dir_to_character.y = 0.0;
	float distance_to_character = length(dir_to_character);
	float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_character/character_radius);
	// Because we operate in vertex space, we need to convert the direction to the character
	// in vertex space. Otherwise, it wouldn't work for rotated blades of grass.
	// comment the next line to observe how the blades are not all facing away from the character.
	dir_to_character = (inverse(MODEL_MATRIX) * vec4(dir_to_character, 0.0)).xyz;
	dir_to_character = normalize(dir_to_character);

	// sample the curve based on how far we are from the character, in normalized coordinates
	float falloff_curve = texture(character_distance_falloff_curve, vec2(falloff)).x;
	// direction to character is inverted because we want to point away from it
	VERTEX += normalize(-dir_to_character) * falloff_curve * character_push_strength * (1.0 - UV.y);
}