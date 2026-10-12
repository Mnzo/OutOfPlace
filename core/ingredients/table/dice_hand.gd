class_name DiceHand
extends Node3D

@export var spacing: float = 0.035
@export var sway_amount: float = 0.003
@export var sway_speed: float = 2.0

var dices: Array[Dice] = []

var _base_position: Vector3
var _time: float = 0.0

func _ready() -> void:
	_base_position = position
	
func _process(delta: float) -> void:
	_time += delta
	position = _base_position + Vector3.UP * sin(_time * sway_speed) * sway_amount
	
func hold(new_dices: Array[Dice]) -> void:
	dices = new_dices
	for i in dices.size():
		var dice: Dice = dices[i]
		dice.freeze = true
		add_child(dice)
		dice.position = Vector3((i - (dices.size() - 1) * 0.5) * spacing, 0, 0)
		dice.rotation = Vector3(randf(), randf(), randf()) * TAU
		
func release() -> Array[Dice]:
	var released: Array[Dice] = dices
	dices = []
	return released
