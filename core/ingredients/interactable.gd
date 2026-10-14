class_name Interactable
extends Area3D

signal interacted

@export var prompt: String = "Interact"
@export var highlight_root: Node3D
@export var highlight_material: Material

var _meshes: Array[GeometryInstance3D] = []

func _ready() -> void:
	collision_layer = 0
	set_collision_layer_value(5, true)
	collision_mask = 0
	monitoring = false
	
	if highlight_root:
		if highlight_root is GeometryInstance3D:
			_meshes.append(highlight_root as GeometryInstance3D)
		for node in highlight_root.find_children("*", "GeometryInstance3D", true, false):
			_meshes.append(node as GeometryInstance3D)
	
func interact() -> void:
	interacted.emit()

func set_focused(focused: bool) -> void:
	for mesh in _meshes:
		mesh.material_overlay = highlight_material if focused else null
