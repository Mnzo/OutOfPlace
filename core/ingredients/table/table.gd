class_name Table
extends Node3D

@onready var seat_camera: Camera3D = %SeatCamera
@onready var thrown_camera: Camera3D = %ThrownCamera
@onready var interactable: Interactable = %Interactable
@onready var dice_launcher: DiceLauncher = %DiceLauncher

@export var ruleset: Ruleset

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	
func _on_interacted() -> void:
	SignalsManager.dice_session_requested.emit(self)
