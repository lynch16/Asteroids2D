# Moves entities as if they are in space: Based on thrust in direction of travel
class_name NavCharacterMovementController
extends MovementController

@export var thrust := 10;
@export_range(PI/12, PI * 4, PI/6) var rotation_speed := PI;

@export var moveable_character: CharacterBody2D;

@onready var nav_agent: NavigationAgent2D = get_node("NavigationAgent2D");
@onready var vision_area: VisionArea = get_node("VisionArea");

var movement_speed: float;

signal navigation_finished;

func _ready() -> void:
	moveable_character.velocity = Vector2.UP;
	movement_speed = moveable_character.velocity.length();
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.navigation_finished.connect(_on_nav_finished);

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if (safe_velocity != Vector2.ZERO):
		moveable_character.velocity = safe_velocity;
		moveable_character.move_and_slide();
	
func _on_nav_finished() -> void:
	navigation_finished.emit();

func _physics_process(delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		nav_agent.set_velocity(moveable_character.velocity)
		return

	# Get next path point from agent
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	
	# Interpolate speed given rate of thrust
	movement_speed = lerp(movement_speed, max_speed, thrust * delta);
	# Apply speed in direction of new target, limited to max speed;
	var new_velocity: Vector2 = moveable_character.global_position.direction_to(next_path_position) * movement_speed;
	var final_velocity := new_velocity.limit_length(max_speed);
	
	var target_rotation := new_velocity.angle();
	var new_angle := lerp_angle(moveable_character.global_rotation, target_rotation, rotation_speed * delta);
	moveable_character.global_rotation = new_angle;
		
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(final_velocity)
	else:
		_on_velocity_computed(new_velocity)

func update_nav_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target;
	
func random_point_in_vision() -> Vector2:
	# TODO: This should be random depth of field as well
	if (!vision_area):
		return Vector2.ZERO;
		
	# TODO: If point is out of bounds, then what?
	return vision_area.get_random_global_point_at_edge_of_vision()

func are_targets_in_sight() -> bool:
	if (!vision_area):
		return false;
		
	return vision_area._can_see_targets();

func get_targets() -> Array[Node2D]:
	if (!vision_area):
		return [];
	
	return vision_area.targets;
