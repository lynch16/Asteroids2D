class_name NavigationController
extends Node

@export var movement_controller: MovementController;
## Dampen how much navigation control asks to update angle
@export var movement_angle_jitter: float = PI/32;
## Angle variance that will stop acceleration and dedicate resources to a hard burn. Can still shoot
@export var hard_turn_angle: float = PI/2;

@export var nav_agent: NavigationAgent2D;

signal navigation_finished

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_nav_finished);
	movement_controller.movement_updated.connect(_on_movement_updated);

func _on_movement_updated(velocity: Vector2, rotation: float) -> void:
	movement_controller.moveable_character.rotation = rotation;
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity);
	else:
		_on_velocity_computed(velocity);

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if (safe_velocity != Vector2.ZERO):
		movement_controller.moveable_character.velocity = safe_velocity;
		movement_controller.moveable_character.move_and_slide();
	
func _on_nav_finished() -> void:
	navigation_finished.emit();

func _physics_process(delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return

	if nav_agent.is_navigation_finished():
		nav_agent.set_velocity(movement_controller.moveable_character.velocity)
		return

	# Get next path point from agent
	var next_path_position: Vector2 = nav_agent.get_next_path_position();
	var next_path_direction := movement_controller.moveable_character.global_position.direction_to(next_path_position);
	var current_dir := Vector2.RIGHT.rotated(movement_controller.moveable_character.global_rotation);
	var path_angle_diff := current_dir.angle_to(next_path_direction);
	
	var hard_burn: float = movement_controller.movement_stats.hard_turn_ratio if abs(path_angle_diff) >= hard_turn_angle else 1.0;

	if (path_angle_diff > movement_angle_jitter):
		movement_controller.yaw_right(delta, hard_burn);
	elif (path_angle_diff < -movement_angle_jitter):
		movement_controller.yaw_left(delta, hard_burn);

	## Only accelerate forward when _not_ running a hard burn
	if (hard_burn != movement_controller.movement_stats.hard_turn_ratio):
		# TODO: Determine when to slow down
		movement_controller.move_forward(delta);

func update_nav_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target;

func get_nav_target() -> Vector2:
	return nav_agent.target_position;
