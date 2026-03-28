shader_type canvas_item;

void fragment() {
	if (FRAGCOORD.y < 10.0) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}