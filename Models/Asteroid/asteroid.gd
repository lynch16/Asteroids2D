class_name Asteroid extends SpawnableCharacter2D

@export var max_velocity := 400; # m/s
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var combat_stats: CombatStats;
@export var health_stats: HealthStats;
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

@onready var death_particles: GPUParticles2D = $DeathParticles2D;
@onready var death_audio_player: AudioStreamPlayer2D = $DeathAudioStreamPlayer2D;
@onready var asteroid_drop: AsteroidDrop = $AsteroidDrop;
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D;

var mass := 10000;
var damageable: Damageable;
var safe_collision_time := 5.0;
var is_dying := false;

signal asteroid_destroyed;

func _enter_tree() -> void:
	super();

	if (!hurtbox):
		hurtbox = %MeshDeformHitHurtbox2D;

	if hurtbox is MeshDeformHitHurtbox2D:
		var deformable_hurtbox: MeshDeformHitHurtbox2D = hurtbox;

		# Propagate stats so only manage at top level
		deformable_hurtbox.combat_stats = combat_stats;
		deformable_hurtbox.health_stats = health_stats;

func _ready() -> void:
	add_to_group("enemy");
	health_stats.resource_local_to_scene = true;
	combat_stats.resource_local_to_scene = true;

	if hurtbox is MeshDeformHitHurtbox2D:
		var deformable_hurtbox: MeshDeformHitHurtbox2D = hurtbox;

		# Connect to mesh deformation results
		deformable_hurtbox.spawn_new_group.connect(_shatter);
		deformable_hurtbox.all_colliders_destroyed.connect(_destroy);

	var invincible_damage_result: InvincibleFramesDamageResult = %InvincibleFramesDamageResult;
	invincible_damage_result.init.connect(_disable_colliders);
	invincible_damage_result.end.connect(_enable_colliders);

	## Dont kill with health b/c these are rocks that dont have health
	# health_stats.on_health_depleted.connect(_destroy);

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
	if (is_dying):
		return;
		
	is_dying = true;

	if (on_screen_notifier.is_on_screen()):
		# asteroid_drop.create_pick_up(); # TODO: Disable drop on kill
		death_particles.emitting = true;
		death_audio_player.playing = true;

	var timer := Timer.new();
	timer.wait_time = death_particles.lifetime;
	timer.autostart = true;
	add_child.call_deferred(timer);
	timer.timeout.connect(_on_dequeue_timeout)

	asteroid_destroyed.emit();

func _on_dequeue_timeout() -> void:
	death_audio_player.playing = false;
	death_particles.emitting = false;
	call_deferred("queue_free");

func deform_mesh(collision_point: Vector2, collision_angle: float, collision_deformation_shapes: Array[MeshDeformationShape]) -> void:
	if hurtbox is MeshDeformHurtbox2D:
		var deformable_hurtbox: MeshDeformHurtbox2D = hurtbox;
		deformable_hurtbox.deformable_mesh_2d.deform_group(
			collision_point,
			collision_angle,
			collision_deformation_shapes
		);
