@tool 
class_name EquipItem 
extends Node2D

@export var use_rate: float = 0.5;

var rotation_speed := 40;
var last_use_time: float;
var aim_angle: float;
var can_use: bool = true;
var owner_character: CharacterBody2D;
var use_target: Node2D;
var action_speed: float; # Speed at which contact is made. ie projectile speed, swing speed

@export var draw_targeting := false;
var last_target_velocities: Array[Vector2] = [];
var max_last_velocities := 5;
var last_velocity_check_time: float;
var last_velocity_check_position: Vector2;

func _process(_delta: float) -> void:
	if (draw_targeting):
		queue_redraw();

func _draw() -> void:
	if (!draw_targeting || !is_instance_valid(use_target)):
		return;
	
	_draw_lead_tracker(calculate_target_aim_point());
	
func _physics_process(delta: float) -> void:
	# TODO: Does this correctly limit rotational speed of weapons?
	# Should this be tied to a boolean as to whether it should be tracking? Eg MissleLauncher wont need this.
	global_rotation = lerp_angle(global_rotation, aim_angle, rotation_speed * delta);
	
	if (use_target):
		if (last_target_velocities.size() > max_last_velocities):
			last_target_velocities.pop_front();
		
		var target_position := use_target.global_position;
		if (target_position != null):
			var new_time := Time.get_unix_time_from_system()
			var time := new_time - last_velocity_check_time;
			last_velocity_check_time = new_time;
			
			var distance := target_position - last_velocity_check_position;
			last_velocity_check_position = target_position;
			
			last_target_velocities.append(distance / time);

func set_aim_direction(aim_dir: Vector2) -> void:
	# Used to physically rotate the weapon towards an aim direction
	aim_angle = get_angle_to(aim_dir)
	
func equip() -> void:
	pass;
	
func unequip() -> void:
	pass;
	
func use() -> void:
	_try_use();
	
func _try_use() -> bool:
	if (!can_use):
		return false;
		
	 # Check if has been long enough since last used
	if (Time.get_unix_time_from_system() - last_use_time < use_rate):
		return false;
	
	last_use_time = Time.get_unix_time_from_system();
	_use();
	
	return true;
	
func _use() -> void:
	pass;
	
func _calculate_target_velocity() -> Vector2:
	var velocity_sum := Vector2.ZERO;
	for v in last_target_velocities:
		velocity_sum += v;
	
	var velocity_count := last_target_velocities.size();
	if (velocity_count > 0):
		return velocity_sum / velocity_count;
	else:
		return Vector2.ZERO;

func calculate_target_aim_point() -> Vector2:
	if (!use_target):
		return global_position;
		
	var projectile_velocity := Vector2(action_speed, 0).rotated(global_rotation);
	var distance := owner_character.global_position.distance_to((use_target.global_position));
	var time_to_hit := ( distance / projectile_velocity.length() );
	var target_velocity := owner_character.velocity + _calculate_target_velocity();
	var aim_point := use_target.global_position + (target_velocity * time_to_hit);
	return aim_point;
	
func _draw_lead_tracker(aim_point: Vector2) -> void:
	var points: PackedVector2Array = [Vector2(), to_local(use_target.global_position), to_local(aim_point)];
	draw_polygon(points, [Color.RED, Color.BLUE, Color.GREEN])
