class_name EquipItem 
extends Node2D

@export var use_rate: float = 0.5;

var rotation_speed := 40;
var last_use_time: float;
var aim_angle: float;
var can_use: bool = true;
var owner_character: CharacterBody2D;

func _process(delta: float) -> void:
	global_rotation = lerp_angle(global_rotation, aim_angle, rotation_speed * delta);

func set_aim_direction(aim_dir: Vector2) -> void:
	aim_angle = aim_dir.angle();

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

func _aim_angle_rotation() -> float:
	return wrapf(aim_angle - PI/2, -PI, PI);
