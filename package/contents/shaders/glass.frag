#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
    vec2 pointer;
    float tileSize;
    float influenceRadius;
    float glassOpacity;
    float refraction;
    float frost;
    float idleStrength;
    float presence;
} ub;
layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D blurredSource;

float roundedBox(vec2 p, vec2 halfSize, float radius) {
    vec2 q = abs(p) - halfSize + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
}
vec3 sampleImage(vec2 pixel) {
    return texture(source, clamp(pixel / ub.resolution, vec2(0.001), vec2(0.999))).rgb;
}
void main() {
    vec2 p = qt_TexCoord0 * ub.resolution;
    vec3 original = sampleImage(p);
    float size = ub.tileSize;
    // Centre the grid; the glass stays stationary as the cursor moves.
    vec2 origin = ub.resolution * 0.5;
    vec2 cell = floor((p - origin) / size);
    vec2 center = origin + (cell + 0.5) * size;
    vec2 local = p - center;
    float halfSize = size * 0.487;
    float radius = size * 0.205;
    float sd = roundedBox(local, vec2(halfSize), radius);
    float mask = 1.0 - smoothstep(-0.8, 0.8, sd);
    float distanceToCursor = length(p - ub.pointer) / ub.influenceRadius;
    float distanceSquared = distanceToCursor * distanceToCursor;
    float halo = exp(-distanceSquared * distanceSquared * 3.0) * ub.presence;
    float strength = clamp(ub.idleStrength + halo * (1.0 - ub.idleStrength), 0.0, 1.0);
    float amount = strength * ub.glassOpacity;
    if (amount < 0.001) {
        fragColor = vec4(original, 1.0) * ub.qt_Opacity;
        return;
    }
    // Rounded-box normal bends the wallpaper most at the thick glass rim.
    vec2 n = normalize(vec2(
        roundedBox(local + vec2(0.5, 0), vec2(halfSize), radius) - roundedBox(local - vec2(0.5, 0), vec2(halfSize), radius),
        roundedBox(local + vec2(0, 0.5), vec2(halfSize), radius) - roundedBox(local - vec2(0, 0.5), vec2(halfSize), radius)
    ) + vec2(0.00001));
    float depth = max(-sd, 0.0);
    float bevel = 1.0 - smoothstep(0.0, size * 0.22, depth);
    vec2 slope = n * bevel * 0.86 + local / halfSize * 0.08;
    vec3 surfaceNormal = normalize(vec3(slope, 1.0));
    // A thick curved edge bends the image, while the centre remains quieter.
    vec3 ray = refract(vec3(0.0, 0.0, -1.0), surfaceNormal, 1.0 / 1.46);
    vec2 bent = p + ray.xy / max(-ray.z, 0.2) * size * 0.65 * ub.refraction
                  - local * 0.045 * ub.refraction;
    vec2 uv = clamp(bent / ub.resolution, vec2(0.001), vec2(0.999));
    vec3 clearGlass = sampleImage(bent);
    vec3 frostGlass = texture(blurredSource, uv).rgb;
    float diffusion = smoothstep(0.0, 0.25, ub.frost);
    vec3 refracted = mix(clearGlass, frostGlass, diffusion);
    refracted = mix(refracted, vec3(0.92, 0.95, 0.96), ub.frost * 0.10);
    // The reflected light direction follows the cursor very gently. It is
    // not a painted white outline around every edge of the tile.
    vec2 lightXY = vec2(-0.65, -0.8) + (ub.pointer - center) / ub.influenceRadius * 0.22;
    vec3 lightDirection = normalize(vec3(lightXY, 1.3));
    vec3 halfVector = normalize(lightDirection + vec3(0.0, 0.0, 1.0));
    float specular = pow(max(dot(surfaceNormal, halfVector), 0.0), 48.0);
    float edgeLight = max(dot(n, normalize(lightXY)), 0.0);
    float edgeShadow = max(dot(n, -normalize(lightXY)), 0.0);
    float fineRim = exp(-abs(sd + 0.9) / 0.8);
    refracted += specular * 0.15 * bevel;
    refracted += fineRim * edgeLight * 0.24;
    refracted -= bevel * edgeShadow * 0.045;
    // A restrained caustic just inside the lower edge gives thickness.
    float caustic = exp(-pow((depth - size * 0.075) / (size * 0.03), 2.0));
    refracted += caustic * edgeShadow * 0.045 * ub.refraction;
    float shadow = exp(-abs(sd - 1.5) / 2.5) * (1.0 - mask);
    vec3 result = mix(original, refracted, mask * amount);
    result *= 1.0 - shadow * amount * 0.16;
    fragColor = vec4(result, 1.0) * ub.qt_Opacity;
}
