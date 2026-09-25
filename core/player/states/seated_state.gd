extends PlayerState

func enter(_previous: StringName, _data := {}) -> void:
	player.velocity = Vector3.ZERO
	player.camera_rotation.look_enabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
