
__constant float magicWidth = 8.0;


void main() {
    vec4 fragColor;
    vec2 posMod = mod( v_tex_coord.xy, magicWidth );
    fragColor = vec4(1.0, 1.0, 1.0, 1.0);

    if (posMod.y < (magicWidth / 4.0)) {
        fragColor.rgb -= 0.1;
    }
    return fragColor;
}
