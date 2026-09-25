extends Node

const PLAYER_CONTROLLER = preload("res://Core/Player/Player.tscn")

func _ready() -> void:
	spawn_player()

func spawn_player() -> void:
	var spawn_point: Node3D = %SpawnPoint
	var entities: Node3D = %Entities
	var new_player = PLAYER_CONTROLLER.instantiate()
	
	new_player.position = spawn_point.global_position
	entities.add_child(new_player)
	
