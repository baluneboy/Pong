
float magicWidth = 1.6 * 4.0;

void main() {
    vec2 posMod = mod( gl_FragCoord.xy, magicWidth );
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    if (posMod.y < (magicWidth / 2.0)) {
        gl_FragColor.rgb -= 0.18;
    }
}
