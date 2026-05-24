class_name NavCharacterMovementController
extends MovementController
## Moves entities as if they are in space: Based on thrust in direction of travel

## TODO: Why is this negative?
@export var flip_speed: float = -TAU * 40.0;

@onready var nav_agent: NavigationAgent2D = get_node("NavigationAgent2D");

var turn_around_active: float;
var start_flip_rotation: float;
var flip_complete_delta_rotation: float = PI/4;
var on_flip_complete: Callable;

signal navigation_finished;

func _ready() -> void:
	movement_speed = moveable_character.velocity.length();

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(moveable_character.velocity)
		
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_nav_finished);

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if (safe_velocity != Vector2.ZERO):
		moveable_character.velocity = safe_velocity;
		moveable_character.move_and_slide();
	
func _on_nav_finished() -> void:
	navigation_finished.emit();

func _physics_process(delta: float) -> void:
	if turn_around_active:
		_flip_rotation(delta);
		return;

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return

	if nav_agent.is_navigation_finished():
		nav_agent.set_velocity(moveable_character.velocity)
		return

	# Get next path point from agent
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	accelerate_movement_speed();
	# Apply speed in direction of new target, limited to max speed;
	var new_velocity: Vector2 = moveable_character.global_position.direction_to(next_path_position) * movement_speed;
	var final_velocity := calculate_moveable_char_velocity(new_velocity);
	
	# Check that it's not zero or character will slowly rotate to face Vector2(0,0);
	if (final_velocity != Vector2.ZERO):
		var target_rotation := final_velocity.angle();
		apply_rotation(target_rotation);
		
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(final_velocity)
	else:
		_on_velocity_computed(final_velocity);

func update_nav_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target;

func get_nav_target() -> Vector2:
	return nav_agent.target_position;

func update_nav_velocity(new_velocity: Vector2) -> void:
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity);

func turn_around(_on_flip_complete: Callable) -> void:
	turn_around_active = true;
	start_flip_rotation = moveable_character.rotation;
	on_flip_complete = _on_flip_complete;

func _flip_rotation(delta: float) -> void:
	var current_rotation := fposmod(moveable_character.rotation, TAU);
	var target_rotation := fposmod(start_flip_rotation + PI, TAU);
	var flip_rotation_speed := exp(flip_speed * delta);
	var new_angle := lerp_angle(current_rotation, target_rotation, flip_rotation_speed);

	moveable_character.rotation = new_angle;
	var final_velocity := moveable_character.velocity.rotated(new_angle);
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(final_velocity)
	else:
		_on_velocity_computed(final_velocity);

	var flip_accuracy := fposmod(target_rotation - current_rotation, TAU);
	if (
		flip_accuracy <= flip_complete_delta_rotation || # Clockwise approach
		flip_accuracy >= TAU - flip_complete_delta_rotation # CCW approach
	):
		turn_around_active = false;
		on_flip_complete.call();
