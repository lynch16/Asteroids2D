@tool
class_name FollowingProjectile
extends Projectile

@export var pursue_delay: float = 1.0; # Time in sec to wait before starting pursue function
var launch_time: float;

func on_start(
	base_velocity: Vector2,
	launch_target: Node2D = null
) -> void:
	super(base_velocity, launch_target);
	launch_time = Time.get_unix_time_from_system();

func update(delta: float) -> void:
	if (launch_time - Time.get_unix_time_from_system() < pursue_delay):
		return;
	
	#if (target is Node2D):
		# Fly towards target
	
