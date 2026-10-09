#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D screen_image;
layout(set = 0, binding = 1) uniform sampler2D palette_tex;

layout(push_constant) uniform PushConstants {
    float pixel_size;         // block size in screen pixels
    float color_levels;       // shades per channel (levels mode)
    float dither_strength;    // 0 = no dithering, 1 = full dithering
    float quantize_gamma;     // levels mode: 2.2 = even, 1.0 = concentrated in shadows
    float vignette_strength;  // 0 = none, 1 = black corners
    float vignette_size;      // distance from center where darkening starts
    float grain_strength;     // amount of animated noise
    float time;               // seconds, drives the grain animation
    float use_palette;        // 0 = levels mode, 1 = palette mode
    float pad0;
    float pad1;
    float pad2;
} pc;

// 2x2 Bayer matrix: the order in which pixels switch to the next color
const float BAYER[4] = float[4](
    0.0, 2.0,
    3.0, 1.0
);

// Cheap pseudo-random number between 0 and 1 from a 2D position
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Exact sRGB conversions, so palette colors land exactly on screen
vec3 linear_to_srgb(vec3 c) {
    return mix(12.92 * c, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), c));
}
vec3 srgb_to_linear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// Perceptual-ish color distance: green matters most to the eye, blue least
float color_distance(vec3 a, vec3 b) {
    vec3 d = a - b;
    return sqrt(dot(d * d, vec3(0.299, 0.587, 0.114)));
}

void main() {
    ivec2 size = imageSize(screen_image);
    int block = max(1, int(pc.pixel_size));

    // Each invocation handles one whole block
    ivec2 block_coord = ivec2(gl_GlobalInvocationID.xy);
    ivec2 block_origin = block_coord * block;
    if (block_origin.x >= size.x || block_origin.y >= size.y) return;

    // 1. Pixelation: read the block's center once
    ivec2 sample_uv = min(block_origin + block / 2, size - 1);
    vec4 color = imageLoad(screen_image, sample_uv);
    vec3 lin = max(color.rgb, vec3(0.0));

    // 2. Vignette (static noisy edge) and animated grain, shared by both modes
    float frame = mod(floor(pc.time * 24.0), 1000.0);
    vec2 uv01 = (vec2(block_origin) + 0.5 * float(block)) / vec2(size);
    vec2 d = uv01 - 0.5;
    d.x *= float(size.x) / float(size.y);  // keep the vignette round
    float edge_noise = (hash(vec2(block_coord) * 1.37) - 0.5) * 0.15;
    float vignette = smoothstep(pc.vignette_size, pc.vignette_size + 0.55, length(d) + edge_noise);
    float darken = 1.0 - vignette * pc.vignette_strength;
    float grain = (hash(vec2(block_coord)
) - 0.5) * pc.grain_strength;

    // Bayer threshold for this block, between 0 and 1
    ivec2 cell = block_coord % 2;
    float bayer01 = (BAYER[cell.y * 2 + cell.x] + 0.5) / 4.0;

    if (pc.use_palette > 0.5) {
        // 3a. Palette mode: compare in sRGB, the space the palette was painted in
        vec3 s = linear_to_srgb(clamp(lin, 0.0, 1.0));
        s = clamp(s * darken + grain, 0.0, 1.0);

        // Find the two closest palette colors
        int count = textureSize(palette_tex, 0).x;
        vec3 best = vec3(0.0);
        vec3 second = vec3(0.0);
        float best_d = 1e9;
        float second_d = 1e9;
        for (int i = 0; i < count; i++) {
            vec3 p = texelFetch(palette_tex, ivec2(i, 0), 0).rgb;
            float dist = color_distance(s, p);
            if (dist < best_d) {
                second = best; second_d = best_d;
                best = p; best_d = dist;
            } else if (dist < second_d) {
                second = p; second_d = dist;
            }
        }

        // How far we are toward the second color (0 = on the best, 0.5 = halfway)
        float ratio = best_d / max(best_d + second_d, 1e-6);
                vec3 chosen = (count > 1 && bayer01 < ratio * pc.dither_strength) ? second : best;
        color.rgb = srgb_to_linear(chosen);
    } else {
        // 3b. Levels mode: per-channel reduction, as before
        float g = max(0.1, pc.quantize_gamma);
        vec3 c = pow(lin, vec3(1.0 / g));
        c = c * darken + grain;
        float threshold = (bayer01 - 0.5) * pc.dither_strength;
        float steps = max(1.0, pc.color_levels - 1.0);
        c = floor(c * steps + 0.5 + threshold) / steps;
        color.rgb = pow(max(c, vec3(0.0)), vec3(g));
    }

    // 4. Fill the whole block with the final color
    for (int y = 0; y < block; y++) {
        for (int x = 0; x < block; x++) {
            ivec2 p = block_origin + ivec2(x, y);
            if (p.x < size.x && p.y < size.y) {
                imageStore(screen_image, p, color);
            }
        }
    }
}