extends Node

@warning_ignore("unused_signal")
signal dice_session_requested(table: Table)

@warning_ignore("unused_signal")
signal player_state_changed(previous: StringName, next: StringName)

@warning_ignore("unused_signal")
signal interaction_focused_changed(prompt: String)

@warning_ignore("unused_signal")
signal dice_session_started(session: SessionState)
@warning_ignore("unused_signal")
signal dice_session_resolved(victory: bool, score: float)
@warning_ignore("unused_signal")
signal dice_session_closed
