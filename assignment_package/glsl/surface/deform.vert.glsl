#version 150

uniform mat4 u_Model;
uniform mat3 u_ModelInvTr;
uniform mat4 u_View;
uniform mat4 u_Proj;
uniform vec3 u_CamP;

uniform int u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec3 fs_Pos;
out vec3 fs_Nor;
out vec3 fs_LightVec;

vec3 cirInter(vec3 pos) {
    float t = sin(0.01 * u_Time - 0.5 * 3.14159) * 0.5 + 0.5;
    t = t * t * (3 - 2 * t);
    vec3 bigCirFinal = 3.5 * normalize(pos.xyz);
    vec3 smallCirFinal = 1 * normalize(pos.xyz);
    int check = int(u_Time / (200 * 3.14159));
    if (check % 2 == 0) {
        return mix(pos, bigCirFinal, t);
    } else {
        return mix(pos, smallCirFinal, t);
    }
}

void main()
{
    // TODO Homework 4
    fs_Nor = normalize(u_ModelInvTr * vec3(vs_Nor));

    vec4 modelposition = u_Model * vs_Pos;
    fs_Pos = vec3(modelposition);
    fs_LightVec = u_CamP - fs_Pos;

    modelposition = vec4(cirInter(modelposition.xyz), 1.f);
    gl_Position = u_Proj * u_View * modelposition;
}
