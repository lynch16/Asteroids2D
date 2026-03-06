class_name Enemy
extends CharacterEntity

@onready var nav_agent: NavigationAgent2D = get_node("NavigationAgent2D");

var movement_speed: float;

func _ready() -> void:
	movement_speed = randf_range(min_speed, max_speed);
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
func set_movement_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target;

func _physics_process(_delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed;
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	rotation = velocity.angle() + PI/2
	move_and_slide();
	
# Enemy Groups
