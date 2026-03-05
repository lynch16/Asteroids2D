class_name PatrolAttackTransition
extends FSMTransition

@export var vision_area: VisionArea;

func is_valid() -> bool:
	if (!vision_area):
		printerr("No vision cone to detect opponents");
		return false;
	
	return vision_area.can_see_targets;

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	print("Target acquired!");
	pass;
