@tool 
class_name RangedWeapon
extends Weapon

@export var ammo_scene: PackedScene;
@export var projectile_speed: float = 1000;

var starting_ammo_count: int = Vector2i.MAX.x;
var current_ammo_count: int;
var shots_per_use := 1;

func _ready() -> void:
	current_ammo_count = starting_ammo_count;
	
func _physics_process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		queue_redraw();

func _use() -> void:
	if current_ammo_count <= 0:
		return;
		
	_use_ammo(shots_per_use);

func _use_ammo(num_ammo: int) -> void:
	for i in num_ammo:
		# TODO: Ammo should be a class
		var ammo := ammo_scene.instantiate() as Bullet;
		
		# TODO: Is root the right place for these to be instantiated?
		# Should projectile management be offloaded to a central utility that can batch?
		add_child(ammo);
		if Engine.is_editor_hint():
			ammo.set_owner(get_tree().edited_scene_root);
		
		current_ammo_count -= i;
		
		ammo.global_position = global_position;
		ammo.global_rotation = owner_character.global_rotation;
		
		var new_velocity := owner_character.velocity + Vector2(projectile_speed, 0).rotated(aim_angle);
		ammo.fire_bullet(new_velocity);

func _draw() -> void:
	if (Engine.is_editor_hint() && aim_target):
		draw_line(position, to_local(aim_target), Color.GREEN)
