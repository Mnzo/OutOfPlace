@abstract
class_name State
extends Node

signal finished(next_state: StringName, data: Dictionary)

func enter(_previous: StringName, _data := {}) -> void: pass
func exit() -> void: pass
func handle_input(_event: InputEvent) -> void: pass
func update(_delta: float) -> void: pass
func physics_update(_delta: float) -> void: pass
