shader_type spatial;

render_mode cull_disabled, specular_schlick_ggx, unshaded, shadows_disabled;

void fragment() {
	ALBEDO = COLOR.rgb;
}
