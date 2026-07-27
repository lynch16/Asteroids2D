class_name Asteroid extends SpawnableCharacter2D

@export var max_velocity := 400; # m/s
@export var combat_stats: CombatStats;
@export var health_stats: HealthStats;
@export var generative_bundle: MS_GenerativeBundle;
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var hurtbox_generator: MS_Generator;
var hitbox_generator: MS_Generator;

var hitbox: Hitbox2D;

var mass := 10000;
var damageable: Damageable;
var safe_collision_time := 5.0;
var is_dying := false;

signal asteroid_destroyed;

func _enter_tree() -> void:
	super();
	hurtbox_generator = $HurtboxGenerator;
	hurtbox_generator.generative_bundle = generative_bundle;
	hurtbox_generator.generate();

	hurtbox = $Hurtbox2D;
	hurtbox.health_stats = health_stats;

	hitbox = Hitbox2D.new(
		combat_stats,
		0.0,
		null,
		HitLog.new(),
		self
	);
	add_child(hitbox);
	hitbox_generator = $HitboxGenerator;
	hitbox_generator.collision_object = hitbox;
	hitbox_generator.generative_bundle = generative_bundle;
	hitbox_generator.generate();

func _ready() -> void:
	add_to_group("enemy");

	health_stats.resource_local_to_scene = true;
	combat_stats.resource_local_to_scene = true;
	generative_bundle.resource_local_to_scene = true;

	hurtbox_generator.generate_new.connect(_shatter);
	hurtbox_generator.degenerate.connect(_destroy);

	var invincible_damage_result: InvincibleFramesDamageResult = %InvincibleFramesDamageResult;
	invincible_damage_result.init.connect(_disable_colliders);
	invincible_damage_result.end.connect(_enable_colliders);

	## Dont kill with health b/c these are rocks that dont have health
	# health_stats.on_health_depleted.connect(_destroy);

func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	velocity = velocity.normalized() * min(velocity.length(), max_velocity);
	move_and_slide();

func _shatter(bundle: MS_GenerativeBundle) -> void:
	AsteroidManager.shatter_asteroid(self, bundle);

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

	var timer := Timer.new();
	timer.wait_time = 1.0;
	timer.autostart = true;
	add_child.call_deferred(timer);
	timer.timeout.connect(_on_dequeue_timeout)

	asteroid_destroyed.emit();

func _on_dequeue_timeout() -> void:
	call_deferred("queue_free");

func deform_mesh(collision_point: Vector2, collision_angle: float, collision_deformation_shapes: Array[MeshDeformationShape]) -> MS_Generator.ShatterResult:
	for shape in collision_deformation_shapes:
		shape.apply_bitmap(
			hurtbox_generator.generative_bundle.ms_canvas.get_tile_position(
				to_local(collision_point)
			),
			collision_angle,
			hurtbox_generator.generative_bundle.ms_bitmap
		);

	var result := hurtbox_generator.shatter();
	
	return result;
