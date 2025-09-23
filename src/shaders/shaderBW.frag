#version 120

uniform sampler2DRect tex0;

uniform float W;
uniform float H;
uniform float vW;
uniform float vH;
uniform float light;
uniform float cameraScale;


void main()
{

    float ratioX = W / vW;
    float ratioY = H / vH;
    vec2 ratio = vec2(ratioX, ratioY);
 
    vec2 texCoord = gl_FragCoord.xy / ratio / cameraScale;

    
	float r = texture2DRect(tex0, texCoord).r * (1 + light / 30.0);
	float g = texture2DRect(tex0, texCoord).r * (1 + light / 30.0);
	float b = texture2DRect(tex0, texCoord).r * (1 + light / 30.0);
	float a = 1.0;
	gl_FragColor = vec4(r, g, b, a);
}