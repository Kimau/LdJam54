shader_type spatial;

render_mode cull_disabled, shadows_disabled, unshaded;

// Pulse Variables
instance uniform float amplitude = 0.001; // How much it pushes the vertex out
instance uniform float width = 0.001; // Width of the pulse
instance uniform float uvpos = 0.0;
instance uniform float progress = 2.0;
instance uniform vec3 extend = vec3(0,0,0);

void vertex() {
	if(extend != vec3(0,0,0)) {
	mat4 inv_model_matrix = inverse(MODEL_MATRIX);
    vec3 vertex_in_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    float tStretch = min(1.0, max(UV.x,0.000001) / 0.2);
    vertex_in_world = vertex_in_world * tStretch + extend * (1.0 - tStretch);
    
    // Convert back to local object space
    VERTEX = (inv_model_matrix * vec4(vertex_in_world, 1.0)).xyz;
	}
	
	{
		float d = max(0, min(1.0, (abs(progress - uvpos) - width) / width));
		float pulse = max(0, 1.0 - abs(UV.x - uvpos) / width);
		
		VERTEX += NORMAL * pulse * amplitude * d;
	}
}

void fragment() {
	if (UV.x > progress)
		discard;
	
	vec3 c = COLOR.rgb;
		
	ALBEDO = c;
}
