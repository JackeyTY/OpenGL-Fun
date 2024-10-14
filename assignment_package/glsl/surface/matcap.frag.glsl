#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader

in vec2 fs_UV;

layout(location = 0) out vec3 out_Col;

void main()
{
    // TODO Homework 4
    vec2 matCapCoord = fs_UV * 0.5 + vec2(0.5, 0.5);
    out_Col = vec3(texture(u_Texture, matCapCoord));
}
