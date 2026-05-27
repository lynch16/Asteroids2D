@tool
class_name FollowerComponent
extends Node2D
## Responsible for applying movement to a node based on the intercept point provided by Intercepter. Movement may be in rotation or position

@export_category("Required properties")
@export var targeter: TargeterComponent: ## The TargeterComponent that tracks the target for the follower
	set(value):
		targeter = value;
		update_configuration_warnings();

@export var movement_controller: MovementController: ## The speed, rotation, acceleration limits of the node_to_move
	set(value):
		movement_controller = value;
		update_configuration_warnings();

@export_category("Movement Settings (required)")
@export var max_follow_range := 200;
@export var max_follow_angle: float = PI/36; ## Variance in rotation from target position that will not cause the node_to_move to rotate. Will also stop rotation once reaching this variance.
@export var accelerate_to_target := false;

func _ready() -> void:
	if (targeter == null):
		targeter = get_node("%TargeterComponent");

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray();
	if (targeter == null):
		warnings.append("FollowerComponent is missing TargeterComponent");
	if (movement_controller == null):
		warnings.append("FollowerComponent is missing MovementController");
	return warnings;

func _process_physics(_delta: float) -> void:
	if (!targeter.is_target_in_sight(max_follow_angle)):
		movement_controller.apply_rotation(targeter.get_target_angle_diff());

	if (!targeter.is_target_in_range(max_follow_range) && accelerate_to_target):
		movement_controller.accelerate_velocity();
