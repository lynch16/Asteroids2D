class_name StateMachine
extends Node2D

@export var _initial_state: FSMState;
@export var move_controller: NavCharacterMovementController;
@export var vision_area: VisionArea;

var _states: Array[FSMState] = [];
var _active_state: FSMState;

func _ready() -> void:
	assert(move_controller is MovementController, "Invalid MoveController assigned to StateMachine: " + move_controller.name);
	assert(vision_area is VisionArea, "Invalid VisionArea assigned to StateMachine: " + vision_area.name);
	
	var children := get_children();
	for child in children:
		assert(child is FSMState, child.name + " is not a valid FSM State")
		_states.push_back(child);
			
	_active_state = _initial_state;
	_active_state.call_deferred("on_enter", null);

func _process(delta: float) -> void:
	update(delta);

func update(_delta: float) -> void:
	for transition in _active_state.transitions:
		if transition.is_valid():
			var ending_state := _active_state.on_exit();
			_active_state = transition.get_next_state();
			transition.on_transition();
			_active_state.on_enter(ending_state);
			break;
			
	_active_state.on_update(_delta);
