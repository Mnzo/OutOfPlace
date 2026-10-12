class_name DiceLauncher
extends Node3D

signal throw_finished(values: Array[int])

@export var dice_scene: PackedScene
@export var hand: DiceHand

@export_group("Throw")
@export var throw_speed: float = 1.4
@export var aim_spread: float = 0.08
@export var spin: float = 25.0
@export var stop_timeout: float = 6.0

var dices: Array[Dice] = []
var is_rolling: bool = false
var is_holding: bool:
	get:
		return not hand.dices.is_empty()

var _elapsed: float = 0.0

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
		dice.freeze = false
		var target: Vector3 = global_position + Vector3(randf_range(-aim_spread, aim_spread), 0, randf_range(-aim_spread, aim_spread))
		var direction: Vector3 = (target - dice.global_position).normalized()
		dice.linear_velocity = direction * throw_speed * randf_range(0.85, 1.15)
		dice.angular_velocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * spin
	_elapsed = 0.0
	is_rolling = true
	
func clear() -> void:
	for dice in dices:
		dice.queue_free()
	dices.clear()
	hand.release()
	is_rolling = false

func _physics_process(delta: float) -> void:
	if not is_rolling:
		return
	_elapsed += delta
	var all_stopped: bool = dices.all(func(d: Dice) -> bool: return d.is_stopped)
	if all_stopped or _elapsed > stop_timeout:
		is_rolling = false
		var values: Array[int] = []
		for dice in dices:
			values.append(dice.read_value())
		throw_finished.emit(values)
