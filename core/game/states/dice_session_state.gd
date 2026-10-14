extends GameState

const Phase := SessionState.Phase
const BLEND_TIME: float = 0.8
const TURN_PAUSE: float = 0.8

var table: Table
var session: SessionState

func enter(_previous: StringName, data := {}) -> void:
	table = data["table"]
	session = SessionState.new(table.ruleset)
	table.dice_launcher.throw_finished.connect(_on_throw_finished)
	
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(player.camera, table.seat_camera, BLEND_TIME)
	player.state_machine.transition_to(Player.SEATED)
	SignalsManager.dice_session_started.emit(session)
	_start_holding()
	
func exit() -> void:
	table.dice_launcher.throw_finished.disconnect(_on_throw_finished)
	
func handle_input(event: InputEvent) -> void:
	var can_quit: bool = session.phase == Phase.HOLDING or session.phase == Phase.CHOOSING
	if can_quit and event.is_action_pressed("ui_cancel"):
		_end(false)
		return
	
	match session.phase:
		Phase.HOLDING:
			if event.is_action_pressed("throw"):
				_throw()
		Phase.CHOOSING:
			if event.is_action_pressed("throw"):
				_start_holding()
			elif event.is_action_pressed("end_turn"):
				_resolve_turn()
				
func _start_holding() -> void:
	session.set_phase(Phase.HOLDING)
	table.dice_launcher.prepare(session.ruleset.dice_count)

func _throw() -> void:
	session.set_phase(Phase.ROLLING)
	session.use_throw()
	table.dice_launcher.throw()

func _on_throw_finished(values: Array[int]) -> void:
	session.set_values(values)
	if session.throws_left > 0:
		session.set_phase(Phase.CHOOSING)
	else:
		_resolve_turn()
		
func _resolve_turn() -> void:
	session.set_phase(Phase.RESOLVING)
	session.bank_turn()
	if session.has_won:
		_end(true)
	elif session.is_out_of_turns:
		_end(false)
	else:
		await get_tree().create_timer(TURN_PAUSE).timeout
		_start_holding()

func _end(victory: bool) -> void:
	finished.emit(GameMode.RESOLUTION, {"table": table, "victory": victory, "score": session.score})
