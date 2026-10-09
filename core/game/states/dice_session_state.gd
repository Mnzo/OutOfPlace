extends GameState

const BLEND_TIME: float = 0.8

var table: Table
var _busy: bool = false

func enter(_previous: StringName, data := {}) -> void:
	table = data["table"]
	_busy = true
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(player.camera, table.seat_camera, BLEND_TIME)
	player.state_machine.transition_to(Player.SEATED)
	_busy = false
	
func handle_input(event: InputEvent) -> void:
	if _busy:
		return
	if event.is_action_pressed("ui_cancel"):
		_leave()

func _leave() -> void:
	_busy = true
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(table.seat_camera, player.camera, BLEND_TIME)
	_busy = false
	finished.emit(GameMode.EXPLORATION, {})
