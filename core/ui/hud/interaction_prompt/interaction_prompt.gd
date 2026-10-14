extends Label

func _ready() -> void:
	SignalsManager.interaction_focused_changed.connect(_on_focus_changed)
	
func _on_focus_changed(prompt: String) -> void:
	visible = not prompt.is_empty()
	if visible:
		text = "[" + InputMap.action_get_events("interact")[0].as_text().split(" ")[0] + "] " + prompt
