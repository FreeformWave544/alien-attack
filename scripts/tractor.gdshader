shader_type canvas_item;

void fragment() {
    vec2 uv = UV;

    // Create cone shape (linear falloff)
    float center = 0.5; // Middle of the beam
    float spread = 0.4; // Width of the cone
    float alpha = smoothstep(center - spread, center, uv.x) * smoothstep(center + spread, center, uv.x);

    // Add fade effect
    alpha *= 1.0 - uv.y;

    // Set final color
    COLOR = vec4(0.2, 0.5, 1.0, alpha);
}