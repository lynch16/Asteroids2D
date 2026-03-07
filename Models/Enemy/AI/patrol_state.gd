class_name PatrolState
extends FSMState

var next_position: Vector2;
var prior_position: Vector2;
@onready var move_controller: NavCharacterMovementController = (get_parent() as StateMachine).move_controller;

#func _ready() -> void:
	# CANNOT CONNECT THROUGH CODE OR STATE TRANSITIONS STOP WORKING FOR SOME REASON
	#move_controller.navigation_finished.connect(get_random_next_position);
	
# TODO: Enemy is returning to base rotation after nav finishes
	
func on_enter(prior_state: FSMState) -> void:
	var last_known_position: Variant = null;
	if prior_state != null:
		last_known_position = prior_state.get("last_known_position");
		if (last_known_position is Vector2):
			next_position = last_known_position;
	
	if (next_position == Vector2.ZERO):
		get_random_next_position();
		move_controller.update_nav_target(next_position);
	
func get_random_next_position() -> void:
	# TODO: Should also rotate randomly within field of view
	var position_in_distance := move_controller.random_point_in_vision();
	if position_in_distance:
		prior_position = next_position;
		next_position = position_in_distance;

func on_update(_delta: float) -> void:
	if (next_position != Vector2.ZERO):
		if (prior_position != next_position):
			prior_position = next_position;
			move_controller.update_nav_target(next_position);
