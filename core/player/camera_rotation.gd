class_name CameraRotation
extends Node3D

@export var sensitivity: float = 0.0005
@export var max_pitch_degrees: float = 88.0

@onready var body: Node3D = owner

var look_enabled: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if not look_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		body.rotate_y(-event.relative.x * sensitivity)
		var limit: float = deg_to_rad(max_pitch_degrees)
		rotation.x = clampf(rotation.x - event.relative.y * sensitivity, -limit, limit)
