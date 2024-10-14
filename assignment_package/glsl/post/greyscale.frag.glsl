#version 330

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

vec3 greyScale(vec3 color) {
    float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
    return vec3(luminance);
}

vec3 vignette(vec3 color) {
    float dis = length(fs_UV - vec2(0.5));
    float vignette = 1.0 - smoothstep(0.2, 0.7, dis);
    return color * vignette;
}

void main()
{
    // TODO Homework 5
    vec4 textColor = texture(u_RenderedTexture, fs_UV);
    color = greyScale(textColor.xyz);
    color = vignette(color);
}
