class_name FSMTransition
extends Node

@export var _next_state: FSMState;

func is_valid() -> bool:
	return true;

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	pass;
