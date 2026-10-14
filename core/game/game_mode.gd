extends Node

const EXPLORATION := &"Exploration"
const DICE_SESSION := &"DiceSession"
const RESOLUTION := &"Resolution"

var player: Player

@onready var state_machine: StateMachine = %StateMachine
@onready var camera_transition: CameraTransition = %CameraTransition
