class_name PatrolState
extends FSMState

var next_position: Vector2;
var prior_position: Vector2;

func on_enter(prior_state: FSMState) -> void:
	var existing_target_info := move_controller.get_nav_target();
	if (existing_target_info != null):
		_set_new_position(existing_target_info);

	var last_known_position: Variant = null;
	if prior_state != null:
		last_known_position = prior_state.get("last_known_position");
		if (last_known_position is Vector2):
			next_position = last_known_position;
	
	if (next_position == Vector2.ZERO):
		get_random_next_position();
		move_controller.update_nav_target(next_position);

	move_controller.navigation_finished.connect(get_random_next_position);

func on_exit() -> FSMState:
	move_controller.navigation_finished.disconnect(get_random_next_position);
	return self;
	
func get_random_next_position() -> void:
	var position_in_distance := targeting_controller.get_random_global_point_at_edge_of_vision();
		
	# If point is outside of viewport, rotate 90 deg
	if (!get_viewport_rect().has_point(position_in_distance)):
		var rotated_position_in_distance := (position_in_distance - global_position).rotated(PI) + global_position;
		move_controller.turn_around(_set_new_position.bind(rotated_position_in_distance));
		return;

	_set_new_position(position_in_distance);

func on_update(_delta: float) -> void:
	if (next_position != Vector2.ZERO):
		if (prior_position != next_position):
			prior_position = next_position;
			move_controller.update_nav_target(next_position);
	else:
		get_random_next_position();
		move_controller.update_nav_target(next_position);

func _set_new_position(new_position: Vector2) -> void:
	prior_position = next_position;
	next_position = new_position;