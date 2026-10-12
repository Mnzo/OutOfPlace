extends Camera3D

@export var speed: float = 5.0
@export var fast_multiplier: float = 2.0
@export var sensitivity: float = 0.0005
@export var toggle_action: StringName = &"debug_camera"
@export var pause_game: bool = false

var is_active: bool = false

var _previous_camera: Camera3D
var _previous_mouse_mode: Input.MouseMode
var _previous_look: bool = false
var _previous_move: bool = false
var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.is_debug_build():
		queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(toggle_action):
		set_active(not is_active)
		get_viewport().set_input_as_handled()
		return
	if not is_active:
		return
		
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * sensitivity
		_pitch = clampf(_pitch - event.relative.y * sensitivity, deg_to_rad(-89), deg_to_rad(89))
		rotation = Vector3(_pitch, _yaw, 0)
	get_viewport().set_input_as_handled()
		
func _process(delta: float) -> void:
	if not is_active:
		return
	
	var input := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W): input.z -= 1
	if Input.is_physical_key_pressed(KEY_S): input.z += 1
	if Input.is_physical_key_pressed(KEY_A): input.x -= 1
	if Input.is_physical_key_pressed(KEY_D): input.x += 1
	if Input.is_physical_key_pressed(KEY_E): input.y += 1
	if Input.is_physical_key_pressed(KEY_Q): input.y -= 1
	
	var move := global_basis * Vector3(input.x, 0, input.z) + Vector3.UP * input.y
	var current_speed := speed * (fast_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
	global_position += move.normalized() * current_speed * delta

func set_active(active: bool) -> void:
	if active == is_active:
		return
	is_active = active

	var player: Player = GameMode.player
	if active:
		_previous_camera = get_viewport().get_camera_3d()
		_previous_mouse_mode = Input.mouse_mode
		if player:
			_previous_look = player.camera_rotation.look_enabled
			_previous_move = player.move_enabled
			player.camera_rotation.look_enabled = false
			player.move_enabled = false
		if _previous_camera:
			global_transform = _previous_camera.global_transform
			fov = _previous_camera.fov
		_yaw = rotation.y
		_pitch = rotation.x
		rotation.z = 0
		make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if is_instance_valid(_previous_camera):
			_previous_camera.make_current()
		if player:
			player.camera_rotation.look_enabled = _previous_look
			player.move_enabled = _previous_move
		Input.mouse_mode = _previous_mouse_mode

	if pause_game:
		get_tree().paused = active
