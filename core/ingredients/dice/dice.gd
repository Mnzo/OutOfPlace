class_name Dice
extends RigidBody3D

const STOP_SPEED: float = 0.02
const STOP_SPIN: float = 0.2
const STOP_TIME: float = 0.25
const MIN_ALIGNMENT: float = 0.9

var is_stopped: bool = false

var _faces: Array[DiceFace] = []
var _stop_time: float = 0.0

func _ready() -> void:
	for child in get_children():
		if child is DiceFace:
			_faces.append(child)
			
func _physics_process(delta: float) -> void:
	if freeze:
		return
	
	var stopped: bool = linear_velocity.length() < STOP_SPEED and angular_velocity.length() < STOP_SPIN
	
	if not stopped:
		_stop_time = 0.0
		is_stopped = false
		return
	if is_stopped:
		return
		
	_stop_time += delta
	if _stop_time < STOP_TIME:
		return
		
	if _alignment(_top_face()) < MIN_ALIGNMENT:
		_nudge()
	else:
		is_stopped = true
		
func read_value() -> int:
	return _top_face().value
		
func _top_face() -> DiceFace:
	var best: DiceFace = _faces[0]
	for face in _faces:
		if _alignment(face) > _alignment(best):
			best = face
	return best
		
func _alignment(face: DiceFace) -> float:
	return (face.global_position - global_position).normalized().dot(Vector3.UP)
		
func _nudge() -> void:
	_stop_time = 0.0
	linear_velocity = Vector3.UP * 0.3
	angular_velocity = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 6.0
