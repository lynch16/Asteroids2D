@tool
class_name CharacterWeapons
extends Node2D

@export var weapon_to_equip: PackedScene;
@export var weapon_target: Node2D;
@export var weapon_targeting_enabled := true;
@export var character: CharacterBody2D;

var current_weapon: Weapon;
var last_target_positions: Array[Vector2] = [];
var max_last_positions := 5;

var target_position_recalc_rate: float = 0.5;
var last_recalc_time: float;

func _ready() -> void:
	if (weapon_to_equip):
		equip_weapon(weapon_to_equip);
	
func _process(_delta: float) -> void:
	queue_redraw();
	
func _draw() -> void:
	if (!is_instance_valid(weapon_target)):
		return;
	if (Time.get_unix_time_from_system() - last_recalc_time < target_position_recalc_rate):
			return;
	
	_draw_lead_tracker();
	
func _physics_process(delta: float) -> void:
	if (weapon_targeting_enabled && current_weapon && weapon_target):
		if (last_target_positions.size() > max_last_positions):
			last_target_positions.pop_front();
		
		var target_position := weapon_target.global_position;
		if (target_position != null):
			last_target_positions.append(target_position)
		
			 # Check if has been long enough since last used
		if (Time.get_unix_time_from_system() - last_recalc_time < target_position_recalc_rate):
			return;
	
		last_recalc_time = Time.get_unix_time_from_system();
		current_weapon.set_aim_direction(calculate_weapon_target_aim_point());
	
func equip_weapon(weapon_scene: PackedScene) -> void:
	if (current_weapon):
		unequip_weapon();
		
	var new_weapon := weapon_scene.instantiate() as Weapon;
	current_weapon = new_weapon;
	add_child(current_weapon)
	current_weapon.global_position = global_position;
	current_weapon.owner_character = character;

	current_weapon.equip();
	
func unequip_weapon() -> void:
	if (!current_weapon):
		return;
	
	current_weapon.unequip();
	current_weapon.queue_free();
	current_weapon = null;
	
func _calculate_target_velocity() -> Vector2:
	var velocity_sum := Vector2.ZERO;
	var velocity_count := 0;
	for i in last_target_positions.size():
		if (i > 0 && i < last_target_positions.size() - 1):
			velocity_sum += last_target_positions[i] - last_target_positions[i-1];
			velocity_count += 1;
	
	if (velocity_count > 0):
		return velocity_sum/velocity_count;
	else:
		return Vector2.ZERO;

func calculate_weapon_target_aim_point() -> Vector2:
	var direction := character.global_rotation + PI/2;
	var projectile_velocity := Vector2.ZERO;
	if (current_weapon is RangedWeapon):
		var current_ranged_weapon: RangedWeapon = current_weapon;
		projectile_velocity = Vector2(current_ranged_weapon.projectile_speed, 0).rotated(direction);
		
	var distance := character.global_position.distance_to((weapon_target.global_position));
	var time_to_hit := ( distance / projectile_velocity.length() );
	var target_velocity := character.velocity + _calculate_target_velocity() * 4;
	var aim_point := weapon_target.global_position + target_velocity * time_to_hit;
	return aim_point;
	
func _draw_lead_tracker() -> void:
	var aim_point := calculate_weapon_target_aim_point();
	var points: PackedVector2Array = [Vector2(), to_local(weapon_target.global_position), to_local(aim_point)];
	draw_polygon(points, [Color.RED, Color.BLUE, Color.GREEN])
