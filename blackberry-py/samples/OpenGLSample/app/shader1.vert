// License http://creativecommons.org/licenses/by-nc-sa/3.0/
// Define a simple GLSL (OpenGL Shading Language) vertex shader.
// More info: http://en.wikipedia.org/wiki/GLSL

attribute vec3 vertexPosition;

uniform mat4 modelViewMatrix;
uniform mat4 perspectiveMatrix;

void main(void) {
    gl_Position = perspectiveMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
}
