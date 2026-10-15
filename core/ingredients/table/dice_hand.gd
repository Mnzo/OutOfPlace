@tool
class_name DiceHand
extends Node3D

@export var area_size: Vector3 = Vector3(0.2, 0.03, 0.08): 
	set = _set_area_size
@export var min_distance: float = 0.055:
	set = _set_min_distance
@export var dice_size: float = 0.03:
	set = _set_dice_size
	
@export_group("Idle")
@export var sway_amount: float = 0.003
@export var sway_speed: float = 2.0

@export_group("Editor Preview")
@export_range(1, 10) var preview_count: int = 5:
	set = _set_preview_count
@export_tool_button("Reshuffle") var reshuffle_action: Callable = _rebuild_preview

var dices: Array[Dice] = []

var _base_position: Vector3
var _time: float = 0.0
var _preview: Node3D

func _ready() -> void:
	_base_position = position
	_rebuild_preview()
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time += delta
	position = _base_position + Vector3.UP * sin(_time * sway_speed) * sway_amount
	
func hold(new_dices: Array[Dice]) -> void:
	dices = new_dices
	var points: Array[Vector3] = _layout(dices.size())
	for i in dices.size():
		var dice: Dice = dices[i]
		dice.freeze = true
		add_child(dice, true)
		dice.position = points[i]
		dice.rotation = Vector3(randf(), randf(), randf()) * TAU
		
func release() -> Array[Dice]:
	var released: Array[Dice] = dices
	dices = []
	return released

func _layout(count: int) -> Array[Vector3]:
	var points: Array[Vector3] = []
	var half: Vector3 = (area_size * 0.5 - Vector3.ONE * dice_size * 0.5).max(Vector3.ZERO)
	for i in count:
		var point: Vector3 = Vector3.ZERO
		for attempt in 30:
			point = Vector3(randf_range(-half.x, half.x), randf_range(-half.y, half.y), randf_range(-half.z, half.x))
			if points.all(func(other: Vector3) -> bool: return other.distance_to(point) >= min_distance):
				break
		points.append(point)
	return points
	
func _rebuild_preview() -> void:
	if not Engine.is_editor_hint():
		return
	if _preview:
		_preview.queue_free()
	_preview = Node3D.new()
	add_child(_preview)
	
	var area: MeshInstance3D = MeshInstance3D.new()
	var area_mesh: BoxMesh = BoxMesh.new()
	area_mesh.size = area_size
	area.mesh = area_mesh
	area.material_override = _ghost_material(Color(1.0, 0.6, 0.1, 0.15))
	_preview.add_child(area)
	
	for point in _layout(preview_count):
		var ghost: MeshInstance3D = MeshInstance3D.new()
		var ghost_mesh: BoxMesh = BoxMesh.new()
		ghost_mesh.size = Vector3.ONE * dice_size
		ghost.mesh = ghost_mesh
		ghost.material_override = _ghost_material(Color(1, 1, 1, 0.6))
		ghost.position = point
		ghost.rotation = Vector3(randf(), randf(), randf()) * TAU
		_preview.add_child(ghost)
		
func _ghost_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
	
func _set_area_size(v: Vector3) -> void: area_size = v; if is_node_ready(): _rebuild_preview()
func _set_min_distance(v: float) -> void: min_distance = v; if is_node_ready(): _rebuild_preview()
func _set_preview_count(v: int) -> void: preview_count = v; if is_node_ready(): _rebuild_preview()
func _set_dice_size(v: float) -> void: dice_size = v; if is_node_ready(): _rebuild_preview()
