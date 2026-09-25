class_name StateMachine
extends Node

@export var initial_state: State

var current: State

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.finished.connect(transition_to)
			
	if initial_state == null:
		push_error("%s: No Initial State set in the Inspector." % owner.name)
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
		return
		
	await owner.ready
	current = initial_state
	current.enter(&"")
	
func _unhandled_input(event: InputEvent) -> void:
	current.handle_input(event)
	
func _process(delta: float) -> void:
	current.update(delta)
	
func _physics_process(delta: float) -> void:
	current.physics_update(delta)
	
func transition_to(next: StringName, data := {}) -> void:
	var next_state := get_node_or_null(NodePath(next)) as State
	
	if next_state == null:
		push_error("%s: state '%s' not found." % [owner.name, next])
		return
		
	var previous := current.name
	current.exit()
	current = next_state
	current.enter(previous, data)
	
	print("%s: %s -> %s" % [owner.name, previous, next])
