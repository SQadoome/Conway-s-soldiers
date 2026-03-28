shader_type canvas_item;
render_mode unshaded;

uniform float influence: hint_range(0.0, 1.0, 0.01) = 0.0;

const float TWO_PI = PI*2.0;

vec3 hsv2rgb(vec3 _c) {
	vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
	return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
	//vec2 centered_pos = vec2(1.0, 1.0) - 2.0*UV;
	vec2 centered_pos = -(2.0*UV - vec2(1.0, 1.0));

	//COLOR.rgb += influence *  hsv2rgb(vec3(1.0 - TIME, 1.0, 1.0));

	COLOR.rgb += hsv2rgb(vec3(TIME, 1.0, 1.0));
}