@tool
class_name Asteroid extends CharacterBody2D

@export var max_velocity := 400; # m/s
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var _combat_stats: CombatStats;
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var hurtbox: MeshDeformHurtbox2D;
var mass := 10000;
var damageable: Damageable;

func _enter_tree() -> void:
	
	hurtbox = MeshDeformHitHurtbox2D.new(
		_combat_stats,
		[
			InvincibleFramesDamageResult.new(),
			ApplyDamageResult.new(),
		],
		collision_mesh_group,
		mesh_deformation_shapes,
		0.0,
		HitLog.new(),
	);
	add_child(hurtbox);
	hurtbox.owner = self;
	hurtbox.spawn_new_group.connect(_shatter);

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
	return hurtbox.get_colliders();

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
