#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform image2D screen_image;

layout(push_constant) uniform PushConstants {
    float pixelation;
    float color_levels;
    float pad0;
    float pad1;
} pc;

void main() {
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = imageSize(screen_image);

    if (uv.x >= size.x || uv.y >= size.y) return;

    vec2 norm_uv = vec2(uv) / vec2(size);
    norm_uv = floor(norm_uv * pc.pixelation) / pc.pixelation;

    ivec2 sample_uv = ivec2(norm_uv * vec2(size));
    vec4 color = imageLoad(screen_image, sample_uv);

    color.rgb = ceil(color.rgb * pc.color_levels) / pc.color_levels;

    imageStore(screen_image, uv, color);
}