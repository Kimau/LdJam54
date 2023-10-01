shader_type spatial;

render_mode cull_disabled, shadows_disabled;

// Pulse Variables
instance uniform float amplitude = 0.001; // How much it pushes the vertex out
instance uniform float width = 0.001; // Width of the pulse
instance uniform float uvpos = 0.0;
instance uniform float progress = 2.0;

void vertex() {
	float d = max(0, min(1.0, (abs(progress - uvpos) - width) / width));
	float pulse = max(0, 1.0 - abs(UV.x - uvpos) / width);
	
	VERTEX += NORMAL * pulse * amplitude * d;
}

void fragment() {
	if (UV.x > progress)
		discard;
	
	vec3 c = COLOR.rgb;
		
	ALBEDO = c;
	EMISSION = c* max(0.01, 1.0 - ((UV.x - progress) / width));
}
