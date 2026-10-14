class_name DiceLauncher
extends Node3D

signal throw_finished(values: Array[int])

const DICE_LAYER: int = 3
const BOUNDS_LAYER: int = 4
const BOUNDS_MARGIN: float = 0.1

@export var dice_scene: PackedScene
@export var hand: DiceHand
@export var bounds: CircularWall

@export_group("Throw")
@export var min_throw_speed: float = 2.0
@export var max_throw_speed: float = 3.0
@export var aim_spread: float = 0.08
@export var spin: float = 25.0
@export var dice_collision_delay: float = 0.2
@export var stop_timeout: float = 6.0

var dices: Array[Dice] = []
var is_rolling: bool = false
var is_holding: bool:
	get:
		return not hand.dices.is_empty()

var _elapsed: float = 0.0
var _outside: Array[Dice] = []
var _dice_collision_on: bool = true

func prepare(count: int) -> void:
	clear()
	var new_dices: Array[Dice] = []
	for i in count:
		new_dices.append(dice_scene.instantiate() as Dice)
	dices = new_dices
	hand.hold(new_dices)

func throw() -> void:
	for dice in hand.release():
		dice.reparent(self)
		dice.set_collision_mask_value(BOUNDS_LAYER, false)
		dice.set_collision_mask_value(DICE_LAYER, false)
		_outside.append(dice)
		dice.freeze = false
		var target: Vector3 = global_position + Vector3(randf_range(-aim_spread, aim_spread) * 2.0, 0, randf_range(-aim_spread, aim_spread))
		var direction: Vector3 = (target - dice.global_position).normalized()
		dice.linear_velocity = direction * randf_range(min_throw_speed, max_throw_speed) * randf_range(0.85, 1.15)
		dice.angular_velocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * spin
	_elapsed = 0.0
	_dice_collision_on = false
	is_rolling = true
	
func clear() -> void:
	for dice in dices:
		dice.queue_free()
	dices.clear()
	_outside.clear()
	hand.release()
	is_rolling = false

func _physics_process(delta: float) -> void:
	if not is_rolling:
		return
	_update_bounds_collision()
		
	_elapsed += delta
	if not _dice_collision_on and _elapsed >= dice_collision_delay:
		_dice_collision_on = true
		for dice in dices:
			dice.set_collision_mask_value(DICE_LAYER, true)
	
	var all_stopped: bool = dices.all(func(d: Dice) -> bool: return d.is_stopped)
	if all_stopped or _elapsed > stop_timeout:
		is_rolling = false
		var values: Array[int] = []
		for dice in dices:
			values.append(dice.read_value())
		throw_finished.emit(values)

func _update_bounds_collision() -> void:
	for i in range(_outside.size() - 1, -1, -1):
		var dice: Dice = _outside[i]
		if _is_inside_bounds(dice):
			dice.set_collision_mask_value(BOUNDS_LAYER, true)
			_outside.remove_at(i)
		
func _is_inside_bounds(dice: Dice) -> bool:
	var offset: Vector3 = dice.global_position - bounds.global_position
	offset.y = 0
	return offset.length() < bounds.radius - BOUNDS_MARGIN
