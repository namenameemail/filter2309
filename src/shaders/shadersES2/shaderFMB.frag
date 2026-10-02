#version 100
precision highp float;

uniform float W;
uniform float H;
uniform float offsetX;
uniform float offsetY;
uniform float scale;
uniform float isWhite;
uniform float light;

void main() {
	vec2 offset = vec2(offsetX, offsetY);
	vec2 uv = (2.0 * gl_FragCoord.xy - vec2(W, H)) / min(W, H);
	vec2 c = uv * scale + offset;
	vec2 z = vec2(0.0);
	int i;
	for (i = 0; i < 100; i++) {
		float x = z.x * z.x - z.y * z.y + c.x;
		float y = 2.0 * z.x * z.y + c.y;
		z = vec2(x, y);
		if (dot(z, z) > 4.0) break;
	}
	float color = float(i) / 100.0;
	float lit = 1.0 + light / 30.0;
	if (isWhite > 0.0) {
		gl_FragColor = vec4(color * lit, color * lit, color * lit, color);
	} else {
		float inv = (1.0 - color) * lit;
		gl_FragColor = vec4(inv, inv, inv, color);
	}
}
