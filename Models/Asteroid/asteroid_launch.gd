class_name AsteroidLaunch
extends Resource

@export var asteroid_mesh: MS_CollisionMeshGroup;
@export var launch_velocity: Vector2;
@export var launch_angle: float;

func _init(
    p_asteroid_mesh: MS_CollisionMeshGroup = MS_CollisionMeshGroup.new(),
    p_launch_velocity: Vector2 = Vector2(),
    p_launch_angle: float = 0.0,
) -> void:
    asteroid_mesh = p_asteroid_mesh;
    launch_velocity = p_launch_velocity;
    launch_angle = p_launch_angle;