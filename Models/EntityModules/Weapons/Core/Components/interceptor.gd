@tool 
class_name Interceptor 
extends Node2D
## Responsible for calculating an intercept point for a given target

@export_category("Required properties")
@export var targeter: Targeter;
@export var intercept_velocity: float; ## How fast the intercept is (how fast the bullet flies)

@export_category("Debug options")
@export var draw_targeting := false; ## Draw a circle to where the targeter is pointing

var max_last_velocities := 5;
var last_target_velocities: Array[Vector2] = [];
var last_target_velocity_check_time: float;
var last_target_velocity_check_position: Vector2;
var last_self_velocities: Array[Vector2] = [];
var last_self_velocity_check_time: float;
var last_self_velocity_check_position: Vector2;

func _process(_delta: float) -> void:
	assert(intercept_velocity != null, "Must set intercept_velocity");

	if (draw_targeting):
		queue_redraw();

func _draw() -> void:
	if (!draw_targeting || !is_instance_valid(targeter.target)):
		return;
	
	_draw_lead_tracker(calculate_intercept_point());
	
func _physics_process(_delta: float) -> void:
	var new_time := Time.get_unix_time_from_system()
	
	if (targeter.target):
		if (last_target_velocities.size() > max_last_velocities):
			last_target_velocities.pop_front();
		
		var target_position := targeter.target.global_position;
		if (target_position != null):
			var target_time := new_time - last_target_velocity_check_time;
			last_target_velocity_check_time = new_time;
			var target_distance := target_position - last_target_velocity_check_position;
			last_target_velocity_check_position = target_position;
			last_target_velocities.append(target_distance / target_time);
	
	# Track own velocity as a Node2D
	if (last_self_velocities.size() > max_last_velocities):
		last_self_velocities.pop_front();
		
	var self_time := new_time - last_self_velocity_check_time;
	last_self_velocity_check_time = new_time;
	var self_distance := global_position - last_self_velocity_check_position;
	last_self_velocity_check_position = global_position;
	last_self_velocities.append(self_distance / self_time);
	
func _calculate_target_velocity() -> Vector2:
	var velocity_sum := Vector2.ZERO;
	for v in last_target_velocities:
		velocity_sum += v;
	
	var velocity_count := last_target_velocities.size();
	if (velocity_count > 0):
		return velocity_sum / velocity_count;
	else:
		return Vector2.ZERO;

func _calculate_self_velocity() -> Vector2:
	var velocity_sum := Vector2.ZERO;
	for v in last_self_velocities:
		velocity_sum += v;
	
	var velocity_count := last_self_velocities.size();
	if (velocity_count > 0):
		return velocity_sum / velocity_count;
	else:
		return Vector2.ZERO;

## Calculate where the target will be at a given action speed
func calculate_intercept_point() -> Vector2:
	if (!targeter.target):
		return global_position;
		
	var projectile_velocity := Vector2(intercept_velocity, 0).rotated(global_rotation);
	var distance := global_position.distance_to((targeter.target.global_position));
	var time_to_hit := ( distance / projectile_velocity.length() );
	var target_v := _calculate_target_velocity();
	var self_v := _calculate_self_velocity();
	var delta_v := target_v - self_v;
	var aim_point := targeter.target.global_position + (delta_v * time_to_hit);
	return aim_point;
	
func _draw_lead_tracker(aim_point: Vector2) -> void:
	var points: PackedVector2Array = [Vector2(), to_local(targeter.target.global_position), to_local(aim_point)];
	draw_polygon(points, [Color.RED, Color.BLUE, Color.GREEN])
