shader_type spatial;
render_mode unshaded;

// Parameters for customization
uniform float dash_length : hint_range(0.01, 1.0) = 0.2;
uniform float gap_length : hint_range(0.01, 1.0) = 0.1;
uniform float animation_speed : hint_range(0.0, 10.0) = 2.0;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_width : hint_range(0.001, 0.1) = 0.01;

// Vertex input
//uniform vec3 vertex;
//uniform vec2 uv;

// Output to fragment shader
varying vec2 v_uv;

void vertex() {
    // Pass UV coordinates for texture sampling
    //v_uv = uv;

    // Transform vertex position (assuming square centered at origin)
    // Adjust scale as needed for your square size
    //vec3 pos = vertex;
    //pos.x *= 0.5; // Scale X
    //pos.z *= 0.5; // Scale Z
    //POSITION = WORLD_MATRIX * vec4(pos, 1.0);
}

void fragment() {
    // Get UV coordinates (0 to 1 range)
    vec2 uv = v_uv;

    // Normalize UV coordinates to square bounds
    vec2 normalized_uv = uv * 2.0 - 1.0; // [-1, 1] range

    // Calculate distance from center
    float dist = length(normalized_uv);

    // Create a square shape (for reference)
    vec2 abs_uv = abs(normalized_uv);
    float square_edge = max(abs_uv.x, abs_uv.y); // Distance to square edge

    // Create dashed line pattern around the square
    float total_dash_length = dash_length + gap_length;
    float time_offset = TIME * animation_speed;

    // Create pattern along X axis (horizontal lines)
    float pattern_x = mod(uv.x * 10.0 + time_offset, total_dash_length);
    bool x_dash = pattern_x < dash_length;

    // Create pattern along Y axis (vertical lines)
    float pattern_y = mod(uv.y * 10.0 + time_offset, total_dash_length);
    bool y_dash = pattern_y < dash_length;

    // Combine patterns for corner detection
    bool draw_line = false;

    // Horizontal lines at top and bottom
    if (abs_uv.y > 0.98 && x_dash) {
        draw_line = true;
    }

    // Vertical lines at left and right
    if (abs_uv.x > 0.98 && y_dash) {
        draw_line = true;
    }

    // Make the lines thinner by checking proximity to edges
    float line_check = min(1.0 - abs_uv.x, 1.0 - abs_uv.y);
    float alpha = 0.0;

    if (draw_line && line_check < line_width) {
        alpha = 1.0;
    }

    // Output color with transparency
    ALBEDO = line_color.rgb;
    ALPHA = alpha * line_color.a;
}