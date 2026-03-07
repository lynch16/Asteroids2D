class_name PatrolAttackTransition
extends FSMTransition

@onready var move_controller: NavCharacterMovementController = (get_parent().get_parent() as StateMachine).move_controller;

func is_valid() -> bool:
	if (!move_controller):
		return false;
	
	return move_controller.are_targets_in_sight();

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target acquired!");
	pass;
