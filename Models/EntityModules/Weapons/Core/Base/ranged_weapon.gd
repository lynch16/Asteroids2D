@tool 
class_name RangedWeapon
extends Weapon
## RangedWeapon is a Weapon that can throw Throwables

## Component that enables the EquipItem to throw packed throwables
@export var thrower: Thrower;
## This is the scene that instantiates a Throwable EquipItem
@export var packed_throwable: PackedScene;
## How many throwables are sent on each use
@export var num_throw_per_use := 1;

var starting_throwable_count: int = Vector2i.MAX.x;
var current_throwable_count: int;
var shots_per_use := 1;

# @export var projectile_scene: PackedScene;
# @export var projectile_speed: float = 1000;


func _ready() -> void:
	current_throwable_count = starting_throwable_count;
	
func _use() -> void:
	if current_throwable_count <= 0:
		# TODO: Out of ammo
		return;

	for i in num_throw_per_use:
		# TODO: Should projectile spawning be offloaded to a central utility that can batch?
		var projectile := packed_throwable.instantiate() as Projectile;
		if Engine.is_editor_hint():
			get_tree().edited_scene_root.add_child(projectile);
			projectile.set_owner(get_tree().edited_scene_root);
		else:
			get_tree().get_root().add_child(projectile);
			
		current_throwable_count -= i;
		
		projectile.use();
	

# func _set_action_speed() -> void:
# 	# Generate projectile, read properties and release
# 	var projectile := projectile_scene.instantiate() as Projectile;
# 	action_speed = projectile.speed;
# 	projectile.queue_free();

# func _send_projectile(num_projectile: int) -> void:
# 	for i in num_projectile:
# 		# TODO: Improve this to be more robust
# 		var projectile: Projectile = projectile_scene.instantiate();
		
		# # TODO: Should projectile management be offloaded to a central utility that can batch?
		# if Engine.is_editor_hint():
		# 	get_tree().edited_scene_root.add_child(projectile);
		# 	projectile.set_owner(get_tree().edited_scene_root);
		# else:
		# 	get_tree().get_root().add_child(projectile);
			
		# current_projectile_count -= i;
		
# 		projectile.on_create(
# 			self,
# 			intercepter.calculate_target_aim_point()
# 		);
		
# 		projectile.on_start(
# 			# Using owner_character velocity b/c this node does not directly track velocity
# 			owner_character.velocity,
# 			intercepter.target
# 		);
