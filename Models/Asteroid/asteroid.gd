@tool
class_name Asteroid extends CharacterBody2D

@export var max_velocity := 400; # m/s
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var _combat_stats: CombatStats;

# TODO: Make rail gun style deformation shape (blast through object until end of screeen)
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var mass := 10000;
var deformable_mesh: DeformableMesh2D;

func _enter_tree() -> void:
	var hurtbox: MeshDeformHurtbox2D = get_node("MeshDeformHurtbox2D");
	deformable_mesh = get_node("DeformableMesh2D");
	
	hurtbox.collision_mesh_group = deformable_mesh._collision_mesh_group;
	deformable_mesh.physics_node = hurtbox;
	hurtbox.spawn_new_group.connect(_shatter);
	hurtbox.combat_stats = _combat_stats;

	var hitbox: MeshDeformHitbox2D = MeshDeformHitbox2D.new(
		_combat_stats,
		0.0, 
		null,
		mesh_deformation_shapes,
	);
	add_child(hitbox);
	hitbox.owner = self;


	var invincible_damage_result_idx := hurtbox.damage_results.find_custom(
		func (dr: DamageResult) -> bool: 
			return dr is InvincibleFramesDamageResult
	);
	if (invincible_damage_result_idx != -1):
		var invincible_damage_result: InvincibleFramesDamageResult = hurtbox.damage_results[invincible_damage_result_idx];	
		invincible_damage_result.init.connect(_disable_colliders);
		invincible_damage_result.end.connect(_enable_colliders);

	_combat_stats.on_health_depleted.connect(_destroy);
	

func _ready() -> void:
	add_to_group("enemy");
	_combat_stats.resource_local_to_scene = true;
	
func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	velocity = velocity.normalized() * min(velocity.length(), max_velocity);
	move_and_slide();

func _shatter(new_mesh_group: MS_CollisionMeshGroup) -> void:
	AsteroidManager.shatter_asteroid(self, new_mesh_group);
		
func get_colliders() -> Array[DeformableMeshCollider2D]:
	return deformable_mesh.get_colliders();

func _disable_colliders() -> void:
	for collision in get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", false);
		

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
