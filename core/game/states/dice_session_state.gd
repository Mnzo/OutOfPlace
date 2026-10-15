extends GameState

const Phase := SessionState.Phase
const BLEND_TIME: float = 0.8
const TURN_PAUSE: float = 0.8
const RAY_LENGTH: float = 10.0
const DICE_MASK := 1 << 2

var table: Table
var session: SessionState

var _dice_focused: Dice

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

func physics_update(_delta: float) -> void:
	var can_hover: bool = session.phase == Phase.HOLDING or session.phase == Phase.CHOOSING
	
	if can_hover:
		var dice_target: Dice = null
		var viewport: Viewport = get_viewport()
		var camera: Camera3D = viewport.get_camera_3d()
		var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
		var mouse_pos: Vector2 = viewport.get_mouse_position()
		var from: Vector3 = camera.project_ray_origin(mouse_pos)
		var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to, DICE_MASK)
		var result := space_state.intersect_ray(query)
		
		if result:
			dice_target = result.collider as Dice
		if _dice_focused == dice_target:
			return
		if is_instance_valid(_dice_focused):
			_dice_focused.set_focused(false)
		_dice_focused = dice_target
		if _dice_focused:
			_dice_focused.set_focused(true)

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
			elif event.is_action_pressed("select_dice"):
				if _dice_focused:
					_dice_focused.set_selected(not _dice_focused.selected)
				
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
