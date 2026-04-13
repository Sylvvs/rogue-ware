shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.4, 0.51, 0.63, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tint_color.rgb, tex.a);
}
