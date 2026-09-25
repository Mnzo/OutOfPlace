class_name CameraShake
extends Node3D

var _duration: float = 0.0
var _period_in_ms: float = 0.0
var _amplitude: float = 0.0
var _timer: float = 0.0
var _last_shook_timer:float = 0.0
var _target_offset: Vector3 = Vector3.ZERO
var _last_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	set_process(true)
	
func _process(delta: float) -> void:
	if _timer <= 0.0:
		return
		
	_timer = delta
	_last_shook_timer = delta
	
	var intensity = _amplitude * (_timer / _duration)
	
	if _last_shook_timer >= _period_in_ms:
		_last_shook_timer = 0.0
		_target_offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			0.0
		)
	
	var new_offset = _last_offset.lerp(_target_offset, delta * (1.0 / _period_in_ms) * 5.0)
	
	position = position - _last_offset + new_offset
	_last_offset = new_offset
	
	_timer = _timer - delta
	if _timer <= 0.0:
		_timer = 0.0
		reset_offset()
		
func shake(duration: float, frequency: float, amplitude: float) -> void:
	if frequency == 0: 
		return
	
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	reset_offset()
	
func reset_offset() -> void:
	position = position - _last_offset
	_last_offset = Vector3.ZERO
