class_name EnemyState
extends FSMState

var move_controller: NavCharacterMovementController;
var vision_area: VisionArea;

func _enter_tree() -> void:
	super();
	var fsm: EnemyStateMachine = get_parent() as EnemyStateMachine;
	move_controller = fsm.move_controller;
	vision_area = fsm.vision_area;

func on_enter(_prior_state: FSMState) -> void:
	pass;

func on_update(_delta: float) -> void:
	pass;
	
func on_exit() -> FSMState:
	return self;
