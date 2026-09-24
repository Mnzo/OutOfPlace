extends Label

var root_viewport_rid: RID

func _ready() -> void:
	root_viewport_rid = get_tree().root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(root_viewport_rid, true)

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var main_thread = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var cpu_time = RenderingServer.viewport_get_measured_render_time_cpu(root_viewport_rid)
	var gpu_time = RenderingServer.viewport_get_measured_render_time_gpu(root_viewport_rid)
	text = "FPS: %d\nGame: %.2f ms\nCPU: %.2f ms\nGPU: %.2f ms" % [fps, main_thread, cpu_time, gpu_time]
