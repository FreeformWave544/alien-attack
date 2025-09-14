shader_type canvas_item;

uniform float current_value : hint_range(0.0, 1.0) = 1.0; // Instant
uniform float lerp_value : hint_range(0.0, 1.0) = 1.0;    // Smooth
uniform vec4 front_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // bright red
uniform vec4 back_color : source_color = vec4(0.4, 0.0, 0.0, 1.0);  // dark red

void fragment() {
    vec2 uv = UV;

    // Fill bars (UV.x goes 0→1 across bar width)
    bool in_front = uv.x < current_value;
    bool in_back  = uv.x < lerp_value;

    if (in_back) {
        COLOR = back_color;
    } else {
        COLOR = vec4(0.0); // transparent background
    }

    if (in_front) {
        COLOR = front_color;
    }
}
