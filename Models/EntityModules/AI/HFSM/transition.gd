class_name FSMTransition
extends Node2D

@export var _next_state: FSMState;

var move_controller: NavCharacterMovementController;
var vision_area: VisionArea;

func _enter_tree() -> void:
	var fsm_state: FSMState = get_parent() as FSMState;
	move_controller = fsm_state.move_controller;
	vision_area = fsm_state.vision_area;

func is_valid() -> bool:
	return true;

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	pass;
