class_name MovementStats
extends Resource

@export var min_speed := 10.0:
	set(val):
		# TODO: https://github.com/godotengine/godot/pull/115649
		min_speed = max(0.0, min(val, max_speed if max_speed != null else Vector2.INF.x)) # Ensures min doesn't exceed max
@export var max_speed := 100.0:
	set(val):
		max_speed = max(min_speed if min_speed != null else 0.0, val) # Ensures max doesn't go below min
@export var thrust := 100.0;
@export var rotation_speed := 5.0;
@export var mass := 2.0;

func _init(
	p_min_speed: float = 10.0,
	p_max_speed: float = 100.0,
	p_thrust: float = 100.0,
	p_rotation_speed: float = 5.0,
	p_mass: float = 2.0,
) -> void:
	min_speed = p_min_speed;
	max_speed = p_max_speed;
	thrust = p_thrust;
	rotation_speed = p_rotation_speed;
	mass = p_mass;
	
