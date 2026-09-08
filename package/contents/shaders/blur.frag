#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    vec2 direction;
    float blurRadius;
} ub;
layout(binding = 1) uniform sampler2D source;
void main() {
    vec2 stepUV = ub.direction * ub.blurRadius / (24.0 * ub.resolution);
    vec4 total = vec4(0.0);
    float weightSum = 0.0;
    for (int i = -24; i <= 24; ++i) {
        float fi = float(i);
        float weight = exp(-0.5 * fi * fi / 100.0);
        total += texture(source, clamp(qt_TexCoord0 + stepUV * fi, vec2(0.0), vec2(1.0))) * weight;
        weightSum += weight;
    }
    fragColor = total / weightSum * ub.qt_Opacity;
}
