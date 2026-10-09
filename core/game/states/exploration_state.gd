extends GameState

func enter(_previous: StringName, _data := {}) -> void:
	SignalsManager.dice_session_requested.connect(_on_dice_session_requested)
	if player:
		player.state_machine.transition_to(Player.FREE_MOVE)

func exit() -> void:
	SignalsManager.dice_session_requested.disconnect(_on_dice_session_requested)
	
func _on_dice_session_requested() -> void:
	finished.emit(GameMode.DICE_SESSION, {})
