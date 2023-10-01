shader_type spatial;
render_mode depth_draw_never, blend_add, cull_disabled;

uniform sampler2D tex;
uniform float blur_size = 0.01;
uniform int num_samples = 10;

void fragment() {
    vec3 c = texture(tex, UV).xyz;
    if (c.g * COLOR.a < 0.1) 
        discard;

    float emission = 0.0;

    // Gaussian weights for blur, assumed num_samples = 10
    float weights[10] = float[10](0.0561, 0.0912, 0.1225, 0.1353, 0.1225, 0.0912, 0.0561, 0.0281, 0.0121, 0.0044);
    
    for(int i = 0; i < num_samples; ++i) {
        float offset = float(i) * blur_size;
        vec2 uv_offset = vec2(offset);
        
        // Sample the texture multiple times around the current fragment's UV
        emission += texture(tex, UV + uv_offset).x * weights[i];
        emission += texture(tex, UV - uv_offset).x * weights[i];
    }
	
	//tint = COLOR

    ALBEDO = COLOR.rgb;
    EMISSION = emission * COLOR.rgb;
}
