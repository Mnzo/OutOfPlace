shader_type spatial;
render_mode cull_disabled;

uniform sampler2D mask_tex : filter_linear_mipmap, repeat_enable; // ta texture noir/blanc
uniform sampler2D color_tex : source_color, filter_linear_mipmap, repeat_enable; // optionnel
uniform bool use_color_tex = false;
uniform vec3 leaf_color : source_color = vec3(0.35, 0.45, 0.2);
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.5;
uniform vec3 backlight_color : source_color = vec3(0.4, 0.6, 0.2);

uniform float wind_strength = 0.15;
uniform float wind_speed = 1.5;
uniform vec3 wind_dir = vec3(1.0, 0.0, 0.3);

void vertex() {
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float phase = dot(wp.xz, vec2(0.35, 0.25));
	float wave = sin(TIME * wind_speed + phase) + 0.5 * sin(TIME * wind_speed * 2.3 + phase * 1.7);
	VERTEX += normalize(wind_dir) * wave * wind_strength * UV.y;
}

void fragment() {
	float mask = texture(mask_tex, UV).r;   // le blanc devient opaque, le noir transparent
	ALBEDO = use_color_tex ? texture(color_tex, UV).rgb : leaf_color;
	ALPHA = mask;
	ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	BACKLIGHT = backlight_color;
}