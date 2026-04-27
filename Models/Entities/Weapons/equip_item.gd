@tool 
class_name EquipItem 
extends Node2D

@export var use_rate: float = 0.5;

var rotation_speed := 40;
var last_use_time: float;
var aim_angle: float;
var can_use: bool = true;
var owner_character: CharacterBody2D;
var action_speed: float; # Speed at which contact is made. ie projectile speed, swing speed

@onready var intercepter: Intercepter = get_node("Intercepter");

func _physics_process(delta: float) -> void:
	# TODO: Does this correctly limit rotational speed of weapons?
	# Should this be tied to a boolean as to whether it should be tracking? Eg MissleLauncher wont need this.
	#global_rotation = lerp_angle(global_rotation, aim_angle, rotation_speed * delta);
	intercepter.action_speed = action_speed;

func set_aim_direction(aim_dir: Vector2) -> void:
	# Used to physically rotate the weapon towards an aim direction
	aim_angle = get_angle_to(aim_dir)

func set_target(new_target: Node2D) -> void:
	intercepter.use_target = new_target;
	
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
	
