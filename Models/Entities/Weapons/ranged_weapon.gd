@tool 
class_name RangedWeapon
extends Weapon

@export var projectile_scene: PackedScene;
@export var projectile_speed: float = 1000;

var starting_projectile_count: int = Vector2i.MAX.x;
var current_projectile_count: int;
var shots_per_use := 1;

func _ready() -> void:
	current_projectile_count = starting_projectile_count;
	action_speed = projectile_speed;
	
func _use() -> void:
	if current_projectile_count <= 0:
		# TODO: Out of ammo
		return;
		
	_send_projectile(shots_per_use);

func _set_action_speed() -> void:
	var projectile := projectile_scene.instantiate() as Projectile;
	action_speed = projectile.speed;
	

func _send_projectile(num_projectile: int) -> void:
	for i in num_projectile:
		var projectile := projectile_scene.instantiate() as Projectile;
		
		# TODO: Should projectile management be offloaded to a central utility that can batch?
		if Engine.is_editor_hint():
			get_tree().edited_scene_root.add_child(projectile);
			projectile.set_owner(get_tree().edited_scene_root);
		else:
			get_tree().get_root().add_child(projectile);
		
		current_projectile_count -= i;
		var aim_point := calculate_target_aim_point();
		
		projectile.on_enter(
			self,
			aim_point
		);
		
		projectile.on_start(
			# Using owner_character velocity b/c this node does not directly track velocity
			owner_character.velocity,
			use_target
		);
