extends GameState

const BLEND_TIME: float = 0.8

var table: Table

var _leaving: bool = false

func enter(_previous: StringName, data := {}) -> void:
	table = data["table"]
	_leaving = false
	SignalsManager.dice_session_resolved.emit(data["victory"], data["score"])
	
func exit() -> void:
	table.dice_launcher.clear()
	SignalsManager.dice_session_closed.emit()
	
func handle_input(event: InputEvent) -> void:
	if _leaving:
		return
	if event.is_action_pressed("throw") or event.is_action_pressed("ui_accept"):
		_leave()
		
func _leave() -> void:
	_leaving = true
	player.state_machine.transition_to(Player.CINEMATIC)
	await GameMode.camera_transition.blend(table.seat_camera, player.camera, BLEND_TIME)
	finished.emit(GameMode.EXPLORATION, {})
