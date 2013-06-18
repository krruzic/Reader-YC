precision mediump float;

uniform mat4 u_mvpMatrix;
uniform sampler2D s_texture;

void main() {
    vec4 point = u_mvpMatrix * vec4(gl_PointCoord.x - 0.5, gl_PointCoord.y - 0.5, 0.0, 1.0);
    point.xy += 0.5;
    gl_FragColor = texture2D(s_texture, point.xy);

    if (gl_PointCoord.x < 0.01 || gl_PointCoord.x > 0.99
        || gl_PointCoord.y < 0.01 || gl_PointCoord.y > 0.99)
        gl_FragColor.rgba = vec4(1.0, 0.0, 0.0, 1.0);
}
