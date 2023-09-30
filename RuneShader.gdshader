shader_type spatial;

render_mode cull_disabled, specular_schlick_ggx, unshaded, shadows_disabled;

// Pulse Variables
//instance uniform float speed = 0.1; // How fast the pulse moves
instance uniform float amplitude = 0.001; // How much it pushes the vertex out
instance uniform float width = 0.001; // Width of the pulse
instance uniform float uvpos = 0.0;

void vertex() {
	// float time = TIME * speed;
	float pulse = 1.0 - abs(UV.x - uvpos) / width;
	VERTEX += NORMAL * max(0,pulse) * amplitude;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}
