class_name RangedWeapon
extends Weapon

@export var ammo_scene: PackedScene;
@export var projectile_speed: float = 1000;

var starting_ammo_count: int = Vector2i.MAX.x;
var current_ammo_count: int;
var shots_per_use := 1;

func _ready() -> void:
	current_ammo_count = starting_ammo_count;

func _use() -> void:
	if current_ammo_count <= 0:
		return;
	
	_use_ammo(shots_per_use);

func _use_ammo(num_ammo: int) -> void:
	for i in num_ammo:
		# TODO: Ammo should be a class
		var ammo := ammo_scene.instantiate() as RigidBody2D;
		
		# TODO: Is root the right place for these to be instantiated?
		# Should projectile management be offloaded to a central utility that can batch?
		get_tree().root.add_child(ammo);
		
		current_ammo_count -= i;
		
		ammo.global_position = global_position;
		var direction := owner_character.rotation + aim_angle - PI/2;
		ammo.rotation = owner_character.rotation;
		
		var base_velocity := owner_character.velocity;
		ammo.apply_central_impulse(base_velocity + Vector2(projectile_speed, 0).rotated(direction));
