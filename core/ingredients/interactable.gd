class_name Interactable
extends Area3D

signal interacted

@export var prompt: String = "Interact"

func _ready() -> void:
	collision_layer = 0
	set_collision_layer_value(5, true)
	collision_mask = 0
	monitoring = false
	
func interact() -> void:
	interacted.emit()
