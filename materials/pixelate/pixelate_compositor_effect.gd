@tool
class_name PixelateCompositorEffect
extends CompositorEffect

const SHADER_FILE: RDShaderFile = preload("res://materials/pixelate/pixelate.glsl")

@export_group("Pixelation")
## On: always use fixed_pixel_size. Off: adapt to the screen with target_height.
@export var use_fixed_pixel_size: bool = true
@export_range(1, 16) var fixed_pixel_size: int = 2
@export_range(90.0, 1080.0) var target_height: float = 540.0

@export_group("Color")
@export_range(2, 256) var color_levels: int = 128
@export_range(0.0, 1.0) var dither_strength: float = 1.0
@export_range(1.0, 2.2) var quantize_gamma: float = 2.2

@export_group("Palette")
## On: every pixel uses the closest colors of palette_texture.
@export var use_palette: bool = false
## A PNG with one pixel per color on a single row (e.g. 12 x 1).
@export var palette_texture: Texture2D

@export_group("Vignette and grain")
@export_range(0.0, 1.0) var vignette_strength: float = 0.6
@export_range(0.0, 1.0) var vignette_size: float = 0.45
@export_range(0.0, 0.2) var grain_strength: float = 0.04

var rd: RenderingDevice
var shader_rid: RID
var pipeline_rid: RID
var sampler_rid: RID
var fallback_palette: ImageTexture


func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	if rd == null:
		return
	var shader_spirv := SHADER_FILE.get_spirv()
	if not shader_spirv.compile_error_compute.is_empty():
		push_error("Pixelate shader: " + shader_spirv.compile_error_compute)
		return
	shader_rid = rd.shader_create_from_spirv(shader_spirv)
	pipeline_rid = rd.compute_pipeline_create(shader_rid)

	# Nearest filtering: palette colors must never be blended
	var sampler_state := RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_rid = rd.sampler_create(sampler_state)

	# Bound when no palette is assigned, so the shader always has a texture
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	fallback_palette = ImageTexture.create_from_image(image)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if sampler_rid.is_valid():
			rd.free_rid(sampler_rid)
		if shader_rid.is_valid():
			rd.free_rid(shader_rid)  # also frees the pipeline built from it


func _render_callback(callback_type: int, render_data: RenderData) -> void:
	if rd == null or not pipeline_rid.is_valid():
		return
	if callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT:
		return
	var buffers := render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if buffers == null:
		return
	var size := buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return

	var palette: Texture2D = palette_texture if palette_texture else fallback_palette
	var palette_rid := RenderingServer.texture_get_rd_texture(palette.get_rid())
	if not palette_rid.is_valid():
		return
	var palette_active := use_palette and palette_texture != null

	var pixel_size: int
	if use_fixed_pixel_size:
		pixel_size = fixed_pixel_size
	else:
		pixel_size = maxi(2, roundi(float(size.y) / target_height))

	# One shader invocation per block, groups of 8x8 blocks
	var blocks := Vector2i(
		(size.x + pixel_size - 1) / pixel_size,
		(size.y + pixel_size - 1) / pixel_size)
	var x_groups := (blocks.x - 1) / 8 + 1
	var y_groups := (blocks.y - 1) / 8 + 1

	var push_constant := PackedFloat32Array([
		float(pixel_size), float(color_levels), dither_strength, quantize_gamma,
		vignette_strength, vignette_size, grain_strength, Time.get_ticks_msec() / 1000.0,
		1.0 if palette_active else 0.0, 0.0, 0.0, 0.0,
	])

	var palette_uniform := RDUniform.new()
	palette_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	palette_uniform.binding = 1
	palette_uniform.add_id(sampler_rid)
	palette_uniform.add_id(palette_rid)

	for view in buffers.get_view_count():
		var image := buffers.get_color_layer(view)
		var image_uniform := RDUniform.new()
		image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		image_uniform.binding = 0
		image_uniform.add_id(image)
		var uniform_set := UniformSetCacheRD.get_cache(shader_rid, 0, [image_uniform, palette_uniform])

		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline_rid)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
