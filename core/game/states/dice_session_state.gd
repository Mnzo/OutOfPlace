extends GameState

func enter(_previous: StringName, _data := {}) -> void:
	player.state_machine.transition_to(Player.SEATED)
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		finished.emit(GameMode.EXPLORATION, {})
