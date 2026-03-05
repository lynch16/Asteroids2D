class_name StateMachine
extends Node

@export var _initial_state: FSMState;
@export var stateful_entity: CharacterEntity;

var _states: Array[FSMState] = [];
var _active_state: FSMState;

func _ready() -> void:
	_active_state = _initial_state;
	_active_state.on_enter();
	
	if stateful_entity is not CharacterEntity:
		printerr("Invalid CharacterEntity assigned to StateMachine: ", stateful_entity);
	
	var children := get_children();
	for child in children:
		if (child is not FSMState):
			printerr(child.name + " is not a valid FSM State");
		else:
			_states.push_back(child);

func _process(delta: float) -> void:
	update(delta);

func update(_delta: float) -> void:
	for transition in _active_state.transitions:
		if transition.is_valid():
			_active_state.on_exit();
			_active_state = transition.get_next_state();
			transition.on_transition();
			_active_state.on_enter();
			break;
			
	_active_state.on_update(_delta);
