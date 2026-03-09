class_name PatrolState
extends FSMState

@export var vision_area: VisionArea;
@export var nav_agent: NavigationAgent2D;
@onready var stateful_entity: CharacterEntity = (get_parent() as StateMachine).stateful_entity;

var next_position: Vector2;

func on_enter(prior_state: FSMState) -> void:
	var last_known_position: Variant = null;
	if prior_state != null:
		last_known_position = prior_state.get("last_known_position");
		if (last_known_position is Vector2):
			next_position = last_known_position;
	
	if (next_position == Vector2.ZERO):
		get_random_next_position();
	
func get_random_next_position() -> void:
	# TODO: Should also rotate randomly within field of view
	var position_in_distance := vision_area.get_random_global_point_at_edge_of_vision();
	if position_in_distance:
		next_position = position_in_distance;

func on_update(_delta: float) -> void:
	if (next_position != Vector2.ZERO):
		(stateful_entity as Enemy).set_movement_target(next_position);
