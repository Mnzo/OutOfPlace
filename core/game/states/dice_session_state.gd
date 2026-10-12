extends GameState

const BLEND_TIME: float = 0.8
const DICE_COUNT: int = 5

var table: Table
var _busy: bool = false

func enter(_previous: StringName, data := {}) -> void:
	table = data["table"]
	table.dice_launcher.throw_finished.connect(_on_throw_finished)
	_busy = true
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(player.camera, table.seat_camera, BLEND_TIME)
	player.state_machine.transition_to(Player.SEATED)
	_busy = false
	
func exit() -> void:
	table.dice_launcher.throw_finished.disconnect(_on_throw_finished)
	table.dice_launcher.clear()
	
func handle_input(event: InputEvent) -> void:
	if _busy:
		return
	var launcher: DiceLauncher = table.dice_launcher
	if event.is_action_pressed("throw"):
		if launcher.is_holding:
			launcher.throw()
		elif not launcher.is_rolling:
			launcher.prepare(DICE_COUNT)
		#_busy = true
		#player.state_machine.transition_to(Player.CINEMATIC)
		#await GameMode.camera_transition.blend(table.seat_camera, table.thr_camera, BLEND_TIME)
		#player.state_machine.transition_to(Player.SEATED)
		#_busy = false
	elif event.is_action_pressed("ui_cancel"):
		_leave()

func _leave() -> void:
	_busy = true
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(table.seat_camera, player.camera, BLEND_TIME)
	_busy = false
	finished.emit(GameMode.EXPLORATION, {})

func _on_throw_finished(values: Array[int]) -> void:
	print("Throw: ", values)
