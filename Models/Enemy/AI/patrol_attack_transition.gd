class_name PatrolAttackTransition
extends FSMTransition

func is_valid() -> bool:
	return targeting_controller.can_see_targets();

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target acquired!");
	pass;
