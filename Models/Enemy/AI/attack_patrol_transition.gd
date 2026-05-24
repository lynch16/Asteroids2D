class_name AttackPatrolTransition
extends FSMTransition

func is_valid() -> bool:
	return !vision_area.can_see_targets();

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target Lost!");
	pass;
