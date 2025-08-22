shader_type canvas_item;

// Uniforms with explicit hint types for Godot 4.x
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;
uniform float wave_frequency : hint_range(0.0, 20.0) = 10.0;
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform vec4 water_color : source_color = vec4(0.2, 0.5, 0.8, 1.0); // Changed to vec4 with source_color
uniform float water_alpha : hint_range(0.0, 1.0) = 0.6;
uniform sampler2D normal_map : hint_normal; // Use hint_normal for normal map texture

// Function to create wave distortion
vec2 wave_distortion(vec2 uv, float time) {
    uv.x += sin(uv.y * wave_frequency + time * wave_speed) * wave_amplitude;
    uv.y += cos(uv.x * wave_frequency + time * wave_speed) * wave_amplitude;
    return uv;
}

void fragment() {
    // Apply wave distortion to UV coordinates
    vec2 distorted_uv = wave_distortion(UV, TIME);

    // Sample the texture with distorted UVs
    vec4 tex_color = texture(TEXTURE, distorted_uv);

    // Sample normal map for lighting effect
    vec3 normal = texture(normal_map, distorted_uv).rgb * 2.0 - 1.0;

    // Simple lighting calculation
    vec3 light_dir = normalize(vec3(1.0, 1.0, 1.0));
    float light = max(0.0, dot(normal, light_dir)) * 0.5 + 0.5;

    // Combine water color with texture and lighting
    vec3 final_color = mix(tex_color.rgb, water_color.rgb, water_alpha) * light;

    // Set final color with alpha
    COLOR = vec4(final_color, tex_color.a * water_alpha);
}
