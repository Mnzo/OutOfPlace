@tool
extends CompositorEffect
class_name PixelateCompositorEffect

@export_range(1.0, 4096.0) var pixelation: float = 812.0
@export_range(1.0, 256.0) var color_levels: float = 20.0

var rd: RenderingDevice
var shader_rid: RID
var pipeline_rid: RID

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	var shader_file = load("res://Materials/Pixelate/Pixelate.glsl")
	var shader_spirv = shader_file.get_spirv()
	shader_rid = rd.shader_create_from_spirv(shader_spirv)
	pipeline_rid = rd.compute_pipeline_create(shader_rid)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader_rid.is_valid(): rd.free_rid(shader_rid)
		if pipeline_rid.is_valid(): rd.free_rid(pipeline_rid)

func _render_callback(p_effect_callback_type: int, p_render_data: RenderData) -> void:
	if p_effect_callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT or not rd:
		return
	var render_scene_buffers := p_render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if not render_scene_buffers:
		return
	var size := render_scene_buffers.get_internal_size()
	if size.x == 0 or size.y == 0:
		return

	var x_groups := ceili(float(size.x) / 8.0)
	var y_groups := ceili(float(size.y) / 8.0)

	var push_constant := PackedFloat32Array([pixelation, color_levels, 0.0, 0.0])

	var view_count := render_scene_buffers.get_view_count()
	for view in range(view_count):
		var color_image: RID = render_scene_buffers.get_color_layer(view)
		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = 0
		uniform.add_id(color_image)
		var uniform_set := UniformSetCacheRD.get_cache(shader_rid, 0, [uniform])
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline_rid)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
