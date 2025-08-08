//
// Atlas grass shader.
//
// Intended for use with MultimeshInstance3D.
//
// Selects UV position from atlas based on vertex red and green colors.
// Selected UV position is rounded to the nearest atlas sector.
// Atlas texture count is set with "texture_count" parameter.
//
// Includes wind sway and trampling effect.
//
// Uses distance to camera for trampling effect, so it will only work for first person game.
// Code can be modified to use arbitrary position as player character position.
//

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert_wrap, specular_disabled, depth_prepass_alpha;

uniform float character_height = 1.85; // Height of the camera above the ground
uniform vec2 texture_count = vec2(4.000000, 4.000000); // Column and row count of textures in atlas
uniform sampler2D main_texture : hint_default_transparent, filter_nearest_mipmap; // Atlas texture

void vertex() {
	float time_offset = sin(fma(TIME + COLOR.r, 2.0, COLOR.g));

	float distance_to_origin = distance(MODELVIEW_MATRIX[3].xyz, vec3(0.0, 0.0, 0.0));
	float character_distance = character_height - distance_to_origin;
	float clamped_character_distance = clamp(character_distance, 0.0, 0.5);

	float wind_modifier = 0.1 - clamped_character_distance;
	float clamped_wind_modifier = clamp(wind_modifier, 0.0, 1.0);
	float wind_offset = time_offset * clamped_wind_modifier;

	vec3 trampled_vertex_modifier = vec3(VERTEX.x, VERTEX.y * -1.0, VERTEX.z);
	float height_based_character_distance = clamped_character_distance * VERTEX.y;

	vec3 trampled_offset = trampled_vertex_modifier * vec3(height_based_character_distance);

	float height_based_wind_offset = VERTEX.y * wind_offset;
	float new_vertex_x = VERTEX.x + height_based_wind_offset;
	float new_vertex_z = VERTEX.z + height_based_wind_offset;
	vec3 new_vertex = vec3(new_vertex_x, VERTEX.y, new_vertex_z);

	VERTEX = new_vertex + trampled_offset;
}

void fragment() {
	vec2 texture_offset = vec2(1.0, 1.0) / texture_count;
	vec2 offset = vec2(
		COLOR.r * texture_count.x,
		COLOR.g * texture_count.y
	);

	vec2 rounded_offset = round(offset);
	vec2 final_offset = rounded_offset * texture_offset;

	vec2 uv_offset = UV * texture_offset;
	vec2 modified_uv = uv_offset + final_offset;

	vec4 color = texture(main_texture, modified_uv);

	ALBEDO = vec3(color.rgb);
	ALPHA = color.a;
}
