#version 330

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

const mat3 sobelHorizontal = mat3(3.0, 10.0, 3.0,
                                  0.0, 0.0, 0.0,
                                  -3.0, -10.0, -3.0);

const mat3 sobelVertical = mat3(3.0, 0.0, -3.0,
                                10.0, 0.0, -10.0,
                                3.0, 0.0, -3.0);

void main()
{
    // TODO Homework 5
    vec3 horSum = vec3(0.f);
    vec3 verSum = vec3(0.f);
    for (int i = 0; i < 3; i++) {
        float curX = gl_FragCoord.x - 1 + i;
        for (int j = 0; j < 3; j++) {
            float curY = gl_FragCoord.y - 1 + j;
            vec3 curColor = texture(u_RenderedTexture, vec2(curX / u_Dimensions.x, curY / u_Dimensions.y)).rgb;
            horSum += curColor * sobelHorizontal[j][i];
            verSum += curColor * sobelVertical[j][i];
        }
    }
    color = sqrt(horSum * horSum + verSum * verSum);
}
