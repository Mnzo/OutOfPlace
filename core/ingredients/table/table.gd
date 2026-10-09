class_name Table
extends Node3D

@onready var seat_camera: Camera3D = %SeatCamera
@onready var interactable: Interactable = %Interactable

func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	
func _on_interacted() -> void:
	SignalsManager.dice_session_requested.emit(self)
