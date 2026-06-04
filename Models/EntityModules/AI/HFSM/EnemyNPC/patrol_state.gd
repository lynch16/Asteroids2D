class_name PatrolState
extends FSMState

@export var randomize_target_on_end: bool = true; # Whether to automatically set a new point to patrol
@export var patrol_jitter_smoothing: int = 0; ## Used to keep patrol in a straight path for x vision area view distances, while still allowing for boundary checks at view distance interval

var pos_jitter_check := 0;

var next_position: Vector2;
var prior_position: Vector2;
var on_finish: Callable;

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

	move_controller.navigation_finished.connect(_on_navigation_finished);

func set_on_navigation_finished(p_on_finish: Callable) -> void:
	on_finish = p_on_finish;

func _on_navigation_finished() -> void:
	if (!on_finish.is_null()):
		on_finish.call();

	if (randomize_target_on_end):
		get_random_next_position();

func on_exit() -> FSMState:
	move_controller.navigation_finished.disconnect(_on_navigation_finished);
	return self;
	
func get_random_next_position() -> void:
	var position_in_distance := vision_area.get_random_global_point_at_edge_of_vision();
		
	# If point is outside of viewport, rotate 90 deg
	if (!get_viewport_rect().has_point(position_in_distance)):
		position_in_distance = (position_in_distance - global_position).rotated(PI) + global_position;
		move_controller.turn_around(_set_new_position.bind(position_in_distance));
		pos_jitter_check = 0;
	else:
		if (pos_jitter_check == patrol_jitter_smoothing):
			pos_jitter_check = 0;
			_set_new_position(position_in_distance);
		else:
			pos_jitter_check += 1;
			var direction := prior_position.angle_to(next_position)
			_set_new_position(
				to_global(Vector2(vision_area.view_distance * (pos_jitter_check + 1), 0).rotated(direction))
			);
	
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
