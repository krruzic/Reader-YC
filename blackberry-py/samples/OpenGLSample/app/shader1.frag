// License http://creativecommons.org/licenses/by-nc-sa/3.0/
// Define a simple GLSL (OpenGL Shading Language) fragment shader.
// More info: http://en.wikipedia.org/wiki/GLSL

#ifdef GL_ES
    precision highp float;
#endif

void main(void) {
    gl_FragColor = vec4(0.4, 0.61, 0.08, 0.8);
}
