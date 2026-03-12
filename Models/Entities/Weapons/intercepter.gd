@tool 
class_name Intercepter 
extends Node2D

var use_target: Node2D;
var action_speed: float; # Speed at which contact is made. ie projectile speed, swing speed

@export var draw_targeting := false;
var max_last_velocities := 5;

var last_target_velocities: Array[Vector2] = [];
var last_target_velocity_check_time: float;
var last_target_velocity_check_position: Vector2;

var last_self_velocities: Array[Vector2] = [];
var last_self_velocity_check_time: float;
var last_self_velocity_check_position: Vector2;

func on_start(
	target: Node2D,
	intercept_speed: float
) -> void:
	use_target = target;
	action_speed = intercept_speed;

func _process(_delta: float) -> void:
	if (draw_targeting):
		queue_redraw();

func _draw() -> void:
	if (!draw_targeting || !is_instance_valid(use_target)):
		return;
	
	_draw_lead_tracker(calculate_target_aim_point());
	
func _physics_process(_delta: float) -> void:
	var new_time := Time.get_unix_time_from_system()
	
	if (use_target):
		if (last_target_velocities.size() > max_last_velocities):
			last_target_velocities.pop_front();
		
		var target_position := use_target.global_position;
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

func calculate_target_aim_point() -> Vector2:
	if (!use_target):
		return global_position;
		
	var projectile_velocity := Vector2(action_speed, 0).rotated(global_rotation);
	var distance := global_position.distance_to((use_target.global_position));
	var time_to_hit := ( distance / projectile_velocity.length() );
	var target_v := _calculate_target_velocity();
	var self_v := _calculate_self_velocity();
	var delta_v := target_v - self_v;
	print("delta_v mag: ", delta_v.length())
	var aim_point := use_target.global_position + (delta_v * time_to_hit);
	return aim_point;
	
func _draw_lead_tracker(aim_point: Vector2) -> void:
	var points: PackedVector2Array = [Vector2(), to_local(use_target.global_position), to_local(aim_point)];
	draw_polygon(points, [Color.RED, Color.BLUE, Color.GREEN])
