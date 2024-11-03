// NOTE: Shader automatically converted from Godot Engine 4.3.stable.mono's StandardMaterial3D.

shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, diffuse_lambert_wrap, specular_disabled, vertex_lighting, fog_disabled;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);
uniform float scroll_speed = 0.001;

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;


void vertex() {
	// Shading Mode: Per Vertex
	ROUGHNESS = roughness;

	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	base_uv.x -= TIME * scroll_speed;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;

	ALBEDO = albedo_tex.rgb;
	
	// Proximity Fade: Enabled
	float depth_tex = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex, 1.0);
	world_pos.xyz /= world_pos.w;
	ALPHA *= clamp(1.0 - smoothstep(world_pos.z + 1.0, world_pos.z, VERTEX.z), 0.0, 1.0);

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * emission_energy;
}
