class_name Asteroid extends SpawnableCharacter2D

@export var max_velocity := 400; # m/s
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var combat_stats: CombatStats;
@export var health_stats: HealthStats;
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var mass := 10000;
var damageable: Damageable;
var safe_collision_time := 5.0;

signal asteroid_destroyed;

func _enter_tree() -> void:
	super();

	var invincible_damage_result := InvincibleFramesDamageResult.new();
	var damage_results := [
		invincible_damage_result,
		ScoreDamageResult.new(),
		MeshDeformDamageResult.new(),
		ParticlesDamageResult.new(),
		ApplyDamageResult.new(),
	];

	# TODO: Why not create a node in editor
	hurtbox = MeshDeformHitHurtbox2D.new(
		combat_stats,
		self,
		collision_mesh_group.duplicate(true) as MS_CollisionMeshGroup, # Duplicate to avoid modifying the original resource which is shared between instances
		health_stats,
		mesh_deformation_shapes,
		0.0,
		HitLog.new(),
	);
	add_child(hurtbox);

	for damage_result: DamageResult in damage_results:
		hurtbox.add_child(damage_result);

	if hurtbox is MeshDeformHurtbox2D:
		var deformable_hurtbox: MeshDeformHurtbox2D = hurtbox;
		deformable_hurtbox.spawn_new_group.connect(_shatter);
		deformable_hurtbox.all_colliders_destroyed.connect(_destroy);

	invincible_damage_result.init.connect(_disable_colliders);
	invincible_damage_result.end.connect(_enable_colliders);

	health_stats.on_health_depleted.connect(_destroy);
	
func _ready() -> void:
	add_to_group("enemy");
	health_stats.resource_local_to_scene = true;
	combat_stats.resource_local_to_scene = true;

func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	velocity = velocity.normalized() * min(velocity.length(), max_velocity);
	move_and_slide();

func _shatter(new_mesh_group: MS_CollisionMeshGroup) -> void:
	AsteroidManager.shatter_asteroid(self, new_mesh_group);

func get_collision_object() -> CollisionObject2D:
	return hurtbox;

func _get_colliders() -> Array[CollisionShape2D]:
	return hurtbox.get_colliders();

func _disable_colliders() -> void:
	for collision in _get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in _get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", false);

func _destroy() -> void:
	call_deferred("queue_free");
	asteroid_destroyed.emit();
	# TODO: Destroy animation

func deform_mesh(collision_point: Vector2, collision_angle: float, collision_deformation_shapes: Array[MeshDeformationShape]) -> void:
	if hurtbox is MeshDeformHurtbox2D:
		var deformable_hurtbox: MeshDeformHurtbox2D = hurtbox;
		deformable_hurtbox.deformable_mesh_2d.deform_group(
			collision_point,
			collision_angle,
			collision_deformation_shapes
		);
