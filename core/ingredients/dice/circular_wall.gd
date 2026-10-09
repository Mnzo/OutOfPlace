@tool
class_name CircularWall
extends StaticBody3D

@export var radius: float = 0.45: set = _set_radius
@export_range(8, 64) var segments: int = 24: set = _set_segments
@export var height: float = 0.1: set = _set_height
@export var thickness: float = 0.05: set = _set_thickness

func _ready() -> void:
	_rebuild()
	
func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
		
	var width: float = 2.0 * radius * tan(PI / segments) * 1.05
	for i in segments:
		var angle: float = TAU * i / segments
		var box: BoxShape3D = BoxShape3D.new()
		box.size = Vector3(width, height, thickness)
		var shape: CollisionShape3D = CollisionShape3D.new()
		shape.shape = box
		shape.rotation.y = angle
		shape.position = Vector3(sin(angle), 0.0, cos(angle)) * (radius + thickness * 0.5) + Vector3.UP * height * 0.5 
		add_child(shape)

func _set_radius(v: float) -> void: radius = v; if is_node_ready(): _rebuild()
func _set_segments(v: int) -> void: segments = v; if is_node_ready(): _rebuild()
func _set_height(v: float) -> void: height = v; if is_node_ready(): _rebuild()
func _set_thickness(v: float) -> void: thickness = v; if is_node_ready(): _rebuild()
