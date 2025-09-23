#version 120

// precision mediump float;


uniform sampler2DRect tex0;

uniform float W;
uniform float H;
uniform float offsetX;
uniform float offsetY;
uniform float scale;
uniform float isWhite;
uniform float light;



void main() {
  
  const int maxIterations = 100;
//   const float scale = 2.5;
vec2 offset = vec2(offsetX, offsetY);
  
  vec2 uv = (2.0 * gl_FragCoord.xy - vec2(W, H)) / min(W, H);

  vec2 c = uv * scale + offset;
  vec2 z = vec2(0.0);
  int i;
  for (i = 0; i < maxIterations; i++) {
	float x = z.x * z.x - z.y * z.y + c.x;
	float y = 2.0 * z.x * z.y + c.y;
	z = vec2(x, y);

	if (dot(z, z) > 4.0) break;
  }
  float color = float(i) / float(maxIterations);

  if (isWhite > 0.0) {
    gl_FragColor = vec4(
      color * (1 + light / 30.0), 
      color * (1 + light / 30.0), 
      color * (1 + light / 30.0), 
      color
      );
  } else {
    gl_FragColor = vec4(
      (1.0 - color)  * (1 + light / 30.0), 
      (1.0 - color)  * (1 + light / 30.0), 
      (1.0 - color)  * (1 + light / 30.0), 
      color);
  }
}


// /* Width and height of screen in pixels */ 
// // uniform vec2 u_resolution;

// /* Point on the complex plane that will be mapped to the center of the screen */
// // uniform vec2 u_zoomCenter;

// /* Distance between left and right edges of the screen. This essentially specifies
//    which points on the plane are mapped to left and right edges of the screen.
//   Together, u_zoomCenter and u_zoomSize determine which piece of the complex
//    plane is displayed. */
// // uniform float u_zoomSize;

// /* How many iterations to do before deciding that a point is in the set. */
// // uniform int u_maxIterations;

// vec2 f(vec2 z, vec2 c) {
// 	// return mat2(z,-z.y,z.z)*z + c;
// 	return mat2(z,-z.y,0)*z + c;
// }

// void main() {
// 	vec2 u_resolution = vec2(vW, vH);
// 	vec2 u_zoomCenter = vec2(0.1,0.1);
// 	float u_zoomSize = 0.5;
// 	int u_maxIterations = 1000;

//   vec2 uv = gl_FragCoord.xy / u_resolution;
  
//   /* Decide which point on the complex plane this fragment corresponds to.*/
//   vec2 c = u_zoomCenter + (uv * 4.0 - vec2(2.0)) * (u_zoomSize / 4.0);
  
//   /* Now iterate the function. */
//   vec2 z = vec2(0.0);
//   bool escaped = false;
//   for (int i = 0; i < 10000; i++) {
//     /* Unfortunately, GLES 2 doesn't allow non-constant expressions in loop
//        conditions so we have to do this ugly thing instead. */
//     if (i > u_maxIterations) break;
//     z = f(z, c);
//     if (length(z) > 2.0) {
//       escaped = true;
//       break;
//     }
//   }
//   gl_FragColor = escaped ? vec4(1.0) : vec4(vec3(0.0), 1.0);
// }