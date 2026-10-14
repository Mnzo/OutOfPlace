class_name Ruleset
extends Resource

@export var target_score: float = 40.0
@export var can_keep_dice: bool = true

@export_range(1, 10) var dice_count: int = 5
@export_range(1, 10) var throw_per_turn: int = 3
@export_range(1, 10) var turns: int = 3
