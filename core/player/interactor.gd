class_name Interactor
extends RayCast3D

var _focused: Interactable

func _physics_process(_delta: float) -> void:
	var target: Interactable = null
	if enabled and is_colliding():
		target = get_collider() as Interactable
	if target == _focused:
		return
	if is_instance_valid(_focused):
		_focused.set_focused(false)
	_focused = target
	if _focused:
		_focused.set_focused(true)
	SignalsManager.interaction_focused_changed.emit(target.prompt if target else "")

func try_interact() -> void:
	if _focused:
		_focused.interact()
