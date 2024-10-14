#version 330

uniform sampler2D u_Texture; // The texture to be read from by this shader
uniform int u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;
in vec3 fs_LightVec;

layout(location = 0) out vec3 out_Col;

vec3 getColor1(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(6.28318 * (c * t + d));
}

vec3 getColor2(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 0.5);
    vec3 d = vec3(0.00, 0.10, 0.20);
    return a + b * cos(6.28318 * (c * t + d));
}

void main()
{
    // TODO Homework 4
    float time = sin(0.05 * u_Time - 0.5 * 3.14159) * 0.5 + 0.5;
    float t1 = dot(normalize(fs_Nor), normalize(fs_LightVec));
    float t2 = dot(normalize(fs_Nor), vec3(time));
    vec3 color = getColor1(t1) + getColor2(t2);
    out_Col = color / 2;
}
