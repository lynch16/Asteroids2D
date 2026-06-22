@tool
class_name StateMachine
extends Node2D

@export var _initial_state: FSMState;
@export var move_controller: MovementController:
	set(value):
		move_controller = value;
		update_configuration_warnings();

@export var vision_area: VisionArea:
	set(value):
		vision_area = value;
		update_configuration_warnings();

var _states: Array[FSMState] = [];
var _active_state: FSMState;

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (move_controller == null):
		warnings.append("StateMachine is missing MovementController");
	if (vision_area == null):
		warnings.append("StateMachine is missing VisionArea");
	return warnings;

func _ready() -> void:
	var children := get_children();
	for child in children:
		assert(child is FSMState, child.name + " is not a valid FSM State")
		_states.push_back(child);
			
	_active_state = _initial_state;
	_active_state.call_deferred("on_enter", null);

func _process(delta: float) -> void:
	if (!Engine.is_editor_hint()):
		update(delta);

func update(_delta: float) -> void:
	if (_active_state != null):
		for transition in _active_state.transitions:
			if transition.is_valid():
				var ending_state := _active_state.on_exit();
				_active_state = transition.get_next_state();
				transition.on_transition();
				_active_state.on_enter(ending_state);
				break;
				
		_active_state.on_update(_delta);
	else:
		_active_state = _initial_state if _initial_state != null else _states[0];
