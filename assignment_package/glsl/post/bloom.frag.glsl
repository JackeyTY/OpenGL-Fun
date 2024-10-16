#version 330

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;
uniform int u_Time;
uniform ivec2 u_Dimensions;

const float kernel[121] = float[](0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799,
                                  0.007941, 0.007795, 0.007559, 0.007239, 0.006849, 0.007239,
                                  0.007653, 0.00799, 0.00824, 0.008394, 0.008446, 0.008394,
                                  0.00824, 0.00799, 0.007653, 0.007239, 0.007559, 0.00799,
                                  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604,
                                  0.008342, 0.00799, 0.007559, 0.007795, 0.00824, 0.008604,
                                  0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604,
                                  0.00824, 0.007795, 0.007941, 0.008394, 0.008764, 0.009039,
                                  0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394,
                                  0.007941, 0.00799, 0.008446, 0.008819, 0.009095, 0.009265,
                                  0.009322, 0.009265, 0.009095, 0.008819, 0.008446, 0.00799,
                                  0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265,
                                  0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.007795,
                                  0.00824, 0.008604, 0.008873, 0.009039, 0.009095, 0.009039,
                                  0.008873, 0.008604, 0.00824, 0.007795, 0.007559, 0.00799,
                                  0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604,
                                  0.008342, 0.00799, 0.007559, 0.007239, 0.007653, 0.00799,
                                  0.00824, 0.008394, 0.008446, 0.008394, 0.00824, 0.00799,
                                  0.007653, 0.007239, 0.006849, 0.007239, 0.007559, 0.007795,
                                  0.007941, 0.00799, 0.007941, 0.007795, 0.007559, 0.007239, 0.006849);

void main()
{
    // TODO Homework 5
    color = texture(u_RenderedTexture, fs_UV).rgb;
    for (int i = 0; i < 11; i++) {
        float curX = gl_FragCoord.x - 5 + i;
        for (int j = 0; j < 11; j++) {
            float curY = gl_FragCoord.y - 5 + j;
            vec3 curColor = texture(u_RenderedTexture, vec2(curX / u_Dimensions.x, curY / u_Dimensions.y)).rgb;
            float luminance = dot(curColor, vec3(0.2126, 0.7152, 0.0722));
            if (luminance > 0.55) {
                color += (curColor * kernel[i * 11 + j]);
            }
        }
    }
}
