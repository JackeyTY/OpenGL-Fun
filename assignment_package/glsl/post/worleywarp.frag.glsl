#version 330

uniform ivec2 u_Dimensions;
uniform int u_Time;

in vec2 fs_UV;

out vec3 color;

uniform sampler2D u_RenderedTexture;

/// credit to https://www.shadertoy.com/view/tlKXzh

//#define WARP_FBM
#define WARP_WORLEY
//#define WARP_PERLIN
#define WARP_FREQUENCY 8.0
#define WARP_MAGNITUDE 0.2

#define FBM
//#define WORLEY
//#define PERLIN
#define NOISE_FREQUENCY 2.0

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

float random1( vec2 p ) {
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);
}

vec2 rotate(vec2 p, float deg) {
    float rad = deg * 3.14159 / 180.0;
    return vec2(cos(rad) * p.x - sin(rad) * p.y,
                sin(rad) * p.x + cos(rad) * p.y);
}

float smootherStep(float a, float b, float t) {
    t = t*t*t*(t*(t*6.0 - 15.0) + 10.0);
    return mix(a, b, t);
}

float interpNoise2D(vec2 uv) {
    vec2 uvFract = fract(uv);
    float ll = random1(floor(uv));
    float lr = random1(floor(uv) + vec2(1,0));
    float ul = random1(floor(uv) + vec2(0,1));
    float ur = random1(floor(uv) + vec2(1,1));
    float lerpXL = smootherStep(ll, lr, uvFract.x);
    float lerpXU = smootherStep(ul, ur, uvFract.x);
    return smootherStep(lerpXL, lerpXU, uvFract.y);
}

float fbm(vec2 uv) {
    float amp = 0.5;
    float freq = 8.0;
    float sum = 0.0;
    int octave = 8;
    for(int i = 0; i < octave; i++) {
        sum += interpNoise2D(uv * freq) * amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    return sum;
}

float WorleyNoise(vec2 uv) {
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.0;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(uvInt + neighbor);

            // Animate the point
            // point = 0.5 + 0.5 * sin(u_Time * 0.01 + 6.2831 * point); // 0 to 1 range

            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

vec2 WorleyNoiseTry(vec2 uv) {
    uv *= 80.f;
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);
    float minDist = 1.0;
    vec2 closest;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(uvInt + neighbor);

            //Animate the point
            point = 0.5 + 0.5 * sin(u_Time * 0.01 + 6.2831 * point); // 0 to 1 range

            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            if (dist < minDist) {
                minDist = dist;
                closest = neighbor + point;
            }
        }
    }
    return (closest + uvInt) / 80.f;
}

float surflet(vec2 P, vec2 gridPoint) {
    float distX = abs(P.x - gridPoint.x);
    float distY = abs(P.y - gridPoint.y);
    float tX = 1.0 - 6.0 * pow(distX, 5.0) + 15.0 * pow(distX, 4.0) - 10.0 * pow(distX, 3.0);
    float tY = 1.0 - 6.0 * pow(distY, 5.0) + 15.0 * pow(distY, 4.0) - 10.0 * pow(distY, 3.0);
    vec2 gradient = random2(gridPoint);
    vec2 diff = P - gridPoint;
    float height = dot(diff, gradient);
    return height * tX * tY;
}

float PerlinNoise(vec2 uv) {
    vec2 uvXLYL = floor(uv);
    vec2 uvXHYL = uvXLYL + vec2(1,0);
    vec2 uvXHYH = uvXLYL + vec2(1,1);
    vec2 uvXLYH = uvXLYL + vec2(0,1);
    return surflet(uv, uvXLYL) + surflet(uv, uvXHYL) + surflet(uv, uvXHYH) + surflet(uv, uvXLYH);
}

vec2 NoiseVectorFBM(vec2 uv) {
    float x = fbm(uv) * 2.0 - 1.0;
    float y = fbm(rotate(uv, 60.0)) * 2.0 - 1.0;
    return vec2(x, y);
}

vec2 NoiseVectorWorley(vec2 uv) {
    float x = WorleyNoise(uv) * 2.0 - 1.0;
    float y = WorleyNoise(rotate(uv, 60.0)) * 2.0 - 1.0;
    return vec2(x, y);
}

vec2 NoiseVectorPerlin(vec2 uv) {
    float x = PerlinNoise(uv);
    float y = PerlinNoise(rotate(uv, 60.0));
    return vec2(x, y);
}

vec3 hash3( vec2 p )
{
    vec3 q = vec3( dot(p,vec2(127.1,311.7)),
                   dot(p,vec2(269.5,183.3)),
                   dot(p,vec2(419.2,371.9)) );
    return fract(sin(q)*43758.5453);
}

float noise( vec2 x, float u, float v )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    float k = 1.0 + 63.0*pow(1.0-v,4.0);
    float va = 0.0;
    float wt = 0.0;
    for( int j=-2; j<=2; j++ ) {
        for( int i=-2; i<=2; i++ ) {
            vec2  g = vec2( float(i), float(j) );
            vec3  o = hash3( p + g )*vec3(u,u,1.0);
            vec2  r = g - f + o.xy;
            float d = dot(r,r);
            float w = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
            va += w*o.z;
            wt += w;
        }
    }
    return va/wt;
}

vec3 getColor(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.8, 0.2, 0.8);
    return a + b * cos(6.28318 * (c * t + d));
}

float pattern( in vec2 p )
{
    vec2 q = vec2( fbm( p + vec2(0.0,0.0) ),
                   fbm( p + vec2(5.2,1.3) ) );

    return fbm( p + 4.0*q );
}

void main()
{
    // TODO Homework 5
//    vec2 warp;
//    #ifdef WARP_FBM
//    warp = NoiseVectorFBM(fs_UV * WARP_FREQUENCY) * WARP_MAGNITUDE;
//    #endif
//    #ifdef WARP_WORLEY
//    warp = NoiseVectorWorley(fs_UV * WARP_FREQUENCY) * WARP_MAGNITUDE;
//    #endif
//    #ifdef WARP_PERLIN
//    warp = NoiseVectorPerlin(fs_UV * WARP_FREQUENCY) * WARP_MAGNITUDE;
//    #endif

//    float h;
//    #ifdef FBM
//    h = fbm(fs_UV * NOISE_FREQUENCY + warp);
//    #endif
//    #ifdef WORLEY
//    h = WorleyNoise(fs_UV * NOISE_FREQUENCY + warp);
//    #endif
//    #ifdef PPERLIN
//    h = PerlinNoise(fs_UV * NOISE_FREQUENCY + warp);
//    #endif
//    color = vec3(h);

    color = texture(u_RenderedTexture, WorleyNoiseTry(fs_UV)).rgb;
//    color = adjustLum(texture(u_RenderedTexture, fs_UV).rgb, noise(25 * fs_UV, 1, 0));
}
