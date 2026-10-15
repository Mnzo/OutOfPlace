class_name Interactable
extends Area3D

signal interacted

@export var prompt: String = "Interact"

@onready var _highlighter: Highlighter = %Highlighter

func _ready() -> void:
	collision_layer = 0
	set_collision_layer_value(5, true)
	collision_mask = 0
	monitoring = false
	
func interact() -> void:
	interacted.emit()

func set_focused(value: bool) -> void:
	_highlighter.hovered = value
