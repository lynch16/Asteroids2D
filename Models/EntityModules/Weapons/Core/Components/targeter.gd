@tool 
class_name TargeterComponent 
extends Node2D
## Responsible for keeping track of target and calculating math to that target for EquipItem Components

@export_category("Optional properties")
@export var target: Node2D; ## Target node

func set_target(new_target: Node2D) -> void:
	target = new_target;

## Check if target is within a minimum distance, regardless of direction
func is_target_in_range(max_range: float) -> bool:
	return get_target_distance() <= max_range;
	
## Check if target is within a cone extending from Intercepter out in radians given by visible_arc_rads
func is_target_in_sight(visible_arc_rads: float) -> bool:
	return abs(get_target_angle_diff()) <= visible_arc_rads;

## Get angle_to from TargeterComponent to Target
func get_target_angle_diff() -> float:
	if (target == null):
		return 0.0;

	return global_position.angle_to(target.global_position);

## Get distance from TargeterComponent to Target
func get_target_distance() -> float:
	if (target == null):
		return 0.0;
		
	return global_position.distance_to(target.global_position);

func get_target_global_position() -> Vector2:
	if (target):
		return target.global_position;
	
	return global_position;