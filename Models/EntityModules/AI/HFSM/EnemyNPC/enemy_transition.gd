class_name EnemyTransition
extends FSMTransition

var move_controller: NavCharacterMovementController;
var vision_area: VisionArea;

func _enter_tree() -> void:
	var fsm_state: EnemyState = get_parent() as EnemyState;
	move_controller = fsm_state.move_controller;
	vision_area = fsm_state.vision_area;

func is_valid() -> bool:
	return true;

func get_next_state() -> FSMState:
	return _next_state;

func on_transition() -> void:
	pass;
