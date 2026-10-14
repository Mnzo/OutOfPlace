class_name SessionState
extends RefCounted

signal changed

enum Phase {
	ENTERING,
	HOLDING,
	ROLLING,
	CHOOSING,
	RESOLVING
}

var ruleset: Ruleset
var phase: Phase = Phase.ENTERING
var turn: int = 1
var throws_left: int = 3
var score: float = 0.0
var values: Array[int] = []

var turn_score: int:
	get:
		return values.reduce(func(total: float, v: float) -> float: return total + v, 0.0)
var has_won: bool:
	get:
		return score >= ruleset.target_score
var is_out_of_turns: bool:
	get:
		return turn > ruleset.turns
		
func _init(p_ruleset: Ruleset) -> void:
	ruleset = p_ruleset
	throws_left = ruleset.throw_per_turn
	
func set_phase(new_phase: Phase) -> void:
	phase = new_phase
	changed.emit()
	
func use_throw() -> void:
	throws_left -= 1
	changed.emit()
	
func set_values(new_values: Array[int]) -> void:
	values = new_values
	changed.emit()
	
func bank_turn() -> void:
	score += turn_score
	turn += 1
	throws_left = ruleset.throw_per_turn
	values = []
	changed.emit()
