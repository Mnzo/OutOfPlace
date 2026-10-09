class_name Player
extends CharacterBody3D

const FREE_MOVE := &"FreeMove"
const SEATED := &"Seated"
const CINEMATIC := &"Cinematic"

@export var walk_speed: float = 4.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var state_machine: StateMachine = %StateMachine
@onready var camera_rotation: CameraRotation = %CameraRotation
@onready var camera: Camera3D = %Camera3D
@onready var interact_ray: RayCast3D = %InteractRay

func _ready() -> void:
	GameMode.player = self

func get_input_direction() -> Vector3:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return (global_basis * Vector3(input.x, 0.0, input.y)).normalized()

func _unhandled_input(event: InputEvent) -> void:  # TEMP: remove once Game drives the player
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		SignalsManager.dice_session_requested.emit()
