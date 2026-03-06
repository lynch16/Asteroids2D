class_name MovementController
extends Node

@export var min_speed := 10.0:
	set(val):
		# TODO: https://github.com/godotengine/godot/pull/115649
		min_speed = max(0, min(val, max_speed if max_speed != null else Vector2i.MAX.x)) # Ensures min doesn't exceed max
@export var max_speed := 100.0:
	set(val):
		max_speed = max(min_speed if min_speed != null else 0, val) # Ensures max doesn't go below min

func _move_forward() -> void:
	pass;

func _move_backward() -> void:
	pass;
	
func _brake() -> void:
	pass;
	
# Rotate direction of travel to the left
func _rotate_left(delta: float) -> void:
	pass;
	
# Rotate direction of travel to the right
func _rotate_right(delta: float) -> void:
	pass;

func constrained_speed(speed: float) -> float:
	return max(
		min_speed, # Constrain larger than min speed
		min(speed, max_speed), # Constrain smaller than max speed
	); 

func _convert_direction_to_rotation(direction: float) -> float:
	return direction + PI/2;
	
func _convert_rotation_to_direction(_rotation: float) -> float:
	return _rotation - PI/2;
