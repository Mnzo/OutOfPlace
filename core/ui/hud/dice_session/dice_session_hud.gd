extends VBoxContainer

const Phase := SessionState.Phase

@onready var turn_label: Label = %TurnLabel
@onready var throws_label: Label = %ThrowsLabel
@onready var score_label: Label = %ScoreLabel
@onready var dice_label: Label = %DiceLabel
@onready var hint_label: Label = %HintLabel

var session: SessionState

func _ready() -> void:
	visible = false
	SignalsManager.dice_session_started.connect(_on_started)
	SignalsManager.dice_session_resolved.connect(_on_resolved)
	SignalsManager.dice_session_closed.connect(_on_closed)
	
func _on_started(new_session: SessionState) -> void:
	session = new_session
	session.changed.connect(_refresh)
	visible = true
	_refresh()
	
func _on_resolved(victory: bool, score: int) -> void:
	session.changed.disconnect(_refresh)
	session = null
	hint_label.text = "Victory! Score: %d" % score if victory else "Defeat. Score: %d" % score

func _on_closed() -> void:
	visible = false
	
func _refresh() -> void:
	var rules: Ruleset = session.ruleset
	turn_label.text = "Turn %d / %d" % [session.turn, rules.turns]
	throws_label.text = "Throws left: %d" % session.throws_left
	score_label.text = "Score: %d/%d" % [session.score, rules.target_score]
	dice_label.text = " ".join(session.values.map(func(v: int) -> String: return str(v)))
	match session.phase:
		Phase.HOLDING:
			hint_label.text = "[SPACE] Throw"
		Phase.CHOOSING:
			hint_label.text = "[SPACE] Rethrow / [ENTER] Keep %d" % session.turn_score
		_:
			hint_label.text = ""
			
