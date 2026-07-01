class_name NavCharacterMovementController
extends MovementController
## Moves entities as if they are in space: Based on thrust in direction of travel

@onready var navigation_controller: NavigationController = get_node("NavigationController");

signal navigation_finished

func _ready() -> void:
	navigation_controller.navigation_finished.connect(_echo_nav_finished);

func update_nav_target(movement_target: Vector2) -> void:
	navigation_controller.nav_agent.target_position = movement_target;

func get_nav_target() -> Vector2:
	return navigation_controller.nav_agent.target_position;

func update_nav_velocity(new_velocity: Vector2) -> void:
	if navigation_controller.nav_agent.avoidance_enabled:
		navigation_controller.nav_agent.set_velocity(new_velocity);

func _echo_nav_finished() -> void:
	navigation_finished.emit();