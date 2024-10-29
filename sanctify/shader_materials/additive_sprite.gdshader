shader_type spatial;

render_mode blend_add, unshaded, specular_disabled, shadows_disabled, depth_test_disabled;

uniform sampler2D sprite_texture : filter_nearest_mipmap_anisotropic;
uniform int frames = 14;
uniform int frame = 0;
uniform float pixel_size = 0.001;
void vertex() {
    mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
	VERTEX.xy *= pixel_size;
}

void fragment() {
	// Calculate the width of each frame in UV space
    float frame_width = 1.0 / float(frames);
	
	// Calculate the UV offset for the current frame
    vec2 frame_uv = vec2(UV.x + float(frame) * frame_width, UV.y);
	
	// Sample the texture with the adjusted UVs
    vec4 tex_color = texture(sprite_texture, frame_uv);

    // Set the output color with transparency support
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
