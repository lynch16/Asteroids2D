class_name AsteroidLaunch
extends Resource

@export var bundle: MS_GenerativeBundle;
@export var launch_position: Vector2;
@export var launch_velocity: Vector2;
@export var launch_angle: float;

func _init(
    p_bundle: MS_GenerativeBundle = MS_GenerativeBundle.new(),
	p_launch_position: Vector2 = Vector2(),
    p_launch_velocity: Vector2 = Vector2(),
    p_launch_angle: float = 0.0,
) -> void:
	bundle = p_bundle;
	launch_position = p_launch_position;
	launch_velocity = p_launch_velocity;
	launch_angle = p_launch_angle;