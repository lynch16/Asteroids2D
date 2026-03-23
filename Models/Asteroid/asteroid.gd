class_name Asteroid extends RigidBody2D

# Change impact spead to use DealDamage

@export var max_velocity := 400; # m/s

@export var debug_collide := false;
@export var debug_random_movement := false;
@export var asteroid_mesh: AsteroidMesh;

var child_number := 0;
var collision_damage := 50.0;

@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
#@onready var collision: CollisionShape2D = get_node("AsteroidCollision");
@onready var mesh_instance: MeshInstance2D = get_node("MeshInstance2D");

var collisions: Array[CollisionShape2D] = [];

func _ready() -> void:
	add_to_group("enemy");
	
	if (asteroid_mesh):
		asteroid_mesh.apply(self, to_global);
	
	# TODO: Players don't cause _on_body_entered
	body_entered.connect(deal_damage.damage);
	
	damageable.on_init(self);
	damageable.on_destroy.connect(_destroy);
	invince_frames_dr.init.connect(_disable_colliders);
	invince_frames_dr.end.connect(_enable_colliders);
	
	# TODO: This should be part of _integrate_forces
	if (debug_collide):
		linear_velocity = Vector2.LEFT * 100;
		
	if (debug_random_movement):
		var direction := rotation;
		direction += randf_range(0, PI/2);
		rotation = direction + PI/2;
		
		# Fly in the direction we're facing
		var velocity := Vector2(
			10.0, 
			0.0
		);
		linear_velocity =  velocity.rotated(rotation - PI/2);
		
func get_mesh_instance() -> MeshInstance2D:
	return mesh_instance;

func get_colliders() -> Array[CollisionShape2D]:
	return collisions;
	
func init_colliders(collider_shapes: Array[Shape2D]) -> void:
	for collider in collisions:
		collider.queue_free();
		
	for shape in collider_shapes:
		var collision := CollisionShape2D.new();
		collision.shape = shape;
		add_child(collision);
		collisions.append(collision);

func _disable_colliders() -> void:
	for collision in collisions:
		collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in collisions:
		collision.set_deferred("disabled", false);
	
func _physics_process(_delta: float) -> void:
	# TODO: This should be part of _integrate_forces
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
	
func handle_projectile(
	last_projectile_position: Vector2, 
	projectile_collision: CollisionShape2D, 
	damage_shapes: Array[DamageShape]
) -> void:
	var colliders := get_colliders();
	var first_collision_points: Array[Vector2] = [];
	var space_state := get_world_2d().direct_space_state;
	
	for collider in colliders:
		var collision_points := projectile_collision.shape.collide_and_get_contacts(
			projectile_collision.global_transform,
			collider.shape,
			collider.global_transform
		);
		
		for point in collision_points:
			var ray_query := PhysicsRayQueryParameters2D.create(
				last_projectile_position,
				point
			);
			ray_query.exclude = [projectile_collision];
			var result := space_state.intersect_ray(ray_query);
			if (result.has("position")):
				first_collision_points.append(result.get("position"));
		
	var cX := 0.0;
	var cY := 0.0;
	
	print("first_collision_points: ", first_collision_points)

	for point in first_collision_points:
		cX += point.x;
		cY += point.y;
		
	var center := Vector2(cX / first_collision_points.size(), cY / first_collision_points.size());
	var orig_samples := asteroid_mesh.corner_sampling;
	var damage_result_samples := TileMapGameControls._apply_damage_shape_to_corner_samples(
		center,
		damage_shapes,
		asteroid_mesh.corner_sampling
	);
	
	var diff_samples: Dictionary[Vector2, Array] = {};
	for key in orig_samples:
		if (damage_result_samples[key] != orig_samples[key]):
			diff_samples[key] = [damage_result_samples[key], orig_samples[key]];
	
	print("DIFF: ", diff_samples);

	asteroid_mesh.update(
		self,
		damage_result_samples,
		get_viewport_rect()
	);
