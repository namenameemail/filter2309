#version 100
precision highp float;

uniform sampler2D tex0;
uniform float W;
uniform float H;
uniform float vW;
uniform float vH;
uniform float light;
uniform float cameraScale;

void main() {
	vec2 ratio = vec2(W / vW, H / vH);
	vec2 texCoordPx = gl_FragCoord.xy / ratio / cameraScale;
	vec2 uv = texCoordPx / vec2(vW, vH);
	float r = texture2D(tex0, uv).r * (1.0 + light / 30.0);
	gl_FragColor = vec4(r, r, r, 1.0);
}
