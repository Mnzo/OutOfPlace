class_name CameraTransition
extends Camera3D

var _tween: Tween

func blend(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if _tween:
		_tween.kill()
	global_transform = from.global_transform
	fov = from.fov
	near = from.near
	make_current()
	
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "global_transform", to.global_transform, duration)
	_tween.tween_property(self, "fov", to.fov, duration)
	await _tween.finished
	to.make_current()
