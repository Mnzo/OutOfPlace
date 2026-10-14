class_name Player
extends CharacterBody3D

const FREE_MOVE := &"FreeMove"
const SEATED := &"Seated"
const CINEMATIC := &"Cinematic"

@export var walk_speed: float = 4.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_enabled: bool = true

@onready var state_machine: StateMachine = %StateMachine
@onready var camera_rotation: CameraRotation = %CameraRotation
@onready var camera: Camera3D = %Camera3D
@onready var interact_ray: RayCast3D = %Interactor

func _ready() -> void:
	GameMode.player = self
	state_machine.transitioned.connect(_on_state_transitioned)

func get_input_direction() -> Vector3:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return (global_basis * Vector3(input.x, 0.0, input.y)).normalized()

func _on_state_transitioned(previous: StringName, next: StringName) -> void:
	SignalsManager.player_state_changed.emit(previous, next)
