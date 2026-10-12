extends PlayerState

func enter(_previous: StringName, _data := {}) -> void:
	player.camera_rotation.look_enabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
		
	var direction: Vector3 = player.get_input_direction() if player.move_enabled else Vector3.ZERO
	player.velocity.x = direction.x * player.walk_speed
	player.velocity.z = direction.z * player.walk_speed
	player.move_and_slide()

func handle_input(event: InputEvent) -> void:
	if player.move_enabled and event.is_action_pressed("interact"):
		player.interact_ray.try_interact()
