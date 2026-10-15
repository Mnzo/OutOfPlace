class_name Highlighter
extends Node

@export var root: Node3D
@export var hovered_material: Material
@export var selected_material: Material

var hovered: bool = false:
	set = _set_hovered
var selected: bool = false:
	set = _set_selected
	
var _meshes: Array[GeometryInstance3D] = []

func _ready() -> void:
	if root == null:
		root = get_parent() as Node3D
	if root is GeometryInstance3D:
		_meshes.append(root as GeometryInstance3D)
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		_meshes.append(node as GeometryInstance3D)

func _set_hovered(value: bool) -> void:
	hovered = value
	_apply()
	
func _set_selected(value: bool) -> void:
	selected = value
	_apply()
	
func _apply() -> void:
	var material: Material = null
	if selected:
		material = selected_material
	elif hovered:
		material = hovered_material
	for mesh in _meshes:
		mesh.material_overlay = material
