class_name PatrolAttackTransition
extends FSMTransition

func is_valid() -> bool:
	return vision_area.can_see_visible_objects();

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target acquired!");
	pass;
