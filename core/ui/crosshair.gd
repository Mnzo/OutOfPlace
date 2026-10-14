extends TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SignalsManager.player_state_changed.connect(_on_player_state_changed)
	
func _on_player_state_changed(_previous: StringName, next: StringName) -> void:
	visible = next == Player.FREE_MOVE
