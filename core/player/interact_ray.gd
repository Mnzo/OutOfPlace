class_name InteractRay
extends RayCast3D

func try_interact() -> void:
	force_raycast_update()
	var target : Object = get_collider()
	if target is Interactable:
		target.interact()
