class_name FSMState
extends Node2D

var move_controller: NavCharacterMovementController;
var targeting_controller: TargetingController;

var transitions: Array[FSMTransition] = [];

func _enter_tree() -> void:
	var fsm: StateMachine = get_parent() as StateMachine;
	move_controller = fsm.move_controller;
	targeting_controller = fsm.targeting_controller;

	var children := get_children();
	for child in children:
		if (child is not FSMTransition):
			printerr(child.name + " is not a valid FSM Transition");
		else:
			transitions.push_back(child);

func on_enter(_prior_state: FSMState) -> void:
	pass;

func on_update(_delta: float) -> void:
	pass;
	
func on_exit() -> FSMState:
	return self;
